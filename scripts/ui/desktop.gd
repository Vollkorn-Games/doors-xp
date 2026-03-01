extends Control

## Main gameplay scene - the Doors XP desktop.
## Manages task windows, taskbar, and routes keyboard input.

const XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")
const TaskWindowScript := preload("res://scripts/tasks/task_window.gd")
const TaskbarButtonScript := preload("res://scripts/ui/taskbar_button.gd")
const ScorePopupScript := preload("res://scripts/ui/score_popup.gd")
const XPWallpaper := preload("res://scripts/ui/xp_wallpaper.gd")
const DesktopIconScript := preload("res://scripts/ui/desktop_icon.gd")
const WindowsFlagScript := preload("res://scripts/ui/windows_flag.gd")
const TaskbarBgScript := preload("res://scripts/ui/xp_taskbar_bg.gd")

const MAX_SLOTS := 8

var _taskbar_buttons: Array = []
var _task_windows: Dictionary = {}  # slot_index -> TaskWindow
var _selected_slot: int = -1
var _popup_container: Control
var _prev_score: int = 0

@onready var _background: ColorRect = %Background
@onready var _task_window_container: CenterContainer = %TaskWindowContainer
@onready var _taskbar_panel: PanelContainer = %TaskbarPanel
@onready var _task_slots_container: HBoxContainer = %TaskSlotsContainer
@onready var _start_button: Button = %StartButton
@onready var _clock_label: Label = %ClockLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _reputation_bar: ProgressBar = %ReputationBar
@onready var _combo_label: Label = %ComboLabel
@onready var _day_label: Label = %DayLabel


func _ready() -> void:
	theme = XPTheme.build_theme()
	_setup_visuals()
	_setup_taskbar()
	_setup_popup_container()
	_connect_signals()

	# If launched directly (not from main menu), start the game
	if GameManager.current_state != GameManager.GameState.PLAYING:
		GameManager.start_new_game()


func _process(_delta: float) -> void:
	_update_clock()
	_update_patience_bars()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	# Check number keys 1-8 for slot selection
	for i in range(MAX_SLOTS):
		if event.is_action_pressed("select_task_%d" % (i + 1)):
			_select_slot(i)
			get_viewport().set_input_as_handled()
			return

	# Forward key to active task window
	if _selected_slot >= 0 and _task_windows.has(_selected_slot):
		var tw = _task_windows[_selected_slot]
		if tw.is_active():
			tw.handle_key_input(key_event)
			get_viewport().set_input_as_handled()


func _setup_visuals() -> void:
	_background.color = Color.TRANSPARENT
	var wallpaper := XPWallpaper.new()
	wallpaper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.add_child(wallpaper)
	_setup_desktop_icons()

	# Taskbar: transparent panel with gradient background behind content
	var taskbar_style := StyleBoxFlat.new()
	taskbar_style.bg_color = Color.TRANSPARENT
	taskbar_style.set_border_width_all(0)
	taskbar_style.content_margin_left = 4.0
	taskbar_style.content_margin_right = 4.0
	taskbar_style.content_margin_top = 3.0
	taskbar_style.content_margin_bottom = 3.0
	_taskbar_panel.add_theme_stylebox_override("panel", taskbar_style)
	var taskbar_bg := TaskbarBgScript.new()
	taskbar_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_taskbar_panel.add_child(taskbar_bg)
	_taskbar_panel.move_child(taskbar_bg, 0)

	# Start button with Windows flag icon + "start" text
	_start_button.text = ""
	_start_button.custom_minimum_size = Vector2(80, 0)
	_start_button.add_theme_stylebox_override("normal", XPTheme.make_start_button_style())
	_start_button.add_theme_stylebox_override("hover", XPTheme.make_start_button_hover())
	_start_button.add_theme_stylebox_override("pressed", XPTheme.make_start_button_style())
	var start_hbox := HBoxContainer.new()
	start_hbox.add_theme_constant_override("separation", 4)
	start_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	start_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_start_button.add_child(start_hbox)
	var flag := WindowsFlagScript.new()
	flag.custom_minimum_size = Vector2(16, 16)
	start_hbox.add_child(flag)
	var start_label := Label.new()
	start_label.text = "start"
	start_label.add_theme_color_override("font_color", XPTheme.TEXT_WHITE)
	start_label.add_theme_font_size_override("font_size", 14)
	start_label.add_theme_constant_override("outline_size", 1)
	start_label.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 1.0, 0.3))
	start_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_hbox.add_child(start_label)

	# System tray / clock area — sunken style
	var tray_panel := PanelContainer.new()
	tray_panel.add_theme_stylebox_override("panel", XPTheme.make_system_tray_style())
	_clock_label.get_parent().remove_child(_clock_label)
	tray_panel.add_child(_clock_label)
	# TaskbarContent is the scene-defined HBox; find it by type since gradient bg was inserted at index 0
	var taskbar_content: HBoxContainer = null
	for child in _taskbar_panel.get_children():
		if child is HBoxContainer:
			taskbar_content = child
			break
	if taskbar_content:
		taskbar_content.add_child(tray_panel)
	_clock_label.add_theme_color_override("font_color", XPTheme.TEXT_WHITE)
	_clock_label.add_theme_font_size_override("font_size", 12)

	# HUD styled as XP toolbar
	_setup_hud_style()


func _setup_hud_style() -> void:
	# Style the HUD top bar as a translucent XP toolbar
	var top_bar: HBoxContainer = _day_label.get_parent() as HBoxContainer
	var hud: Control = top_bar.get_parent()

	# Wrap the top bar + reputation bar in a styled panel
	var toolbar := PanelContainer.new()
	toolbar.add_theme_stylebox_override("panel", XPTheme.make_toolbar_style())
	toolbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Position at top, full width, auto height
	toolbar.anchor_left = 0.0
	toolbar.anchor_right = 1.0
	toolbar.anchor_top = 0.0
	toolbar.anchor_bottom = 0.0
	toolbar.offset_bottom = 0.0
	toolbar.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	var toolbar_vbox := VBoxContainer.new()
	toolbar_vbox.add_theme_constant_override("separation", 2)
	toolbar_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toolbar.add_child(toolbar_vbox)

	# Reparent top bar and reputation bar into the toolbar
	var top_bar_parent := top_bar.get_parent()
	top_bar_parent.remove_child(top_bar)
	top_bar_parent.remove_child(_reputation_bar)
	toolbar_vbox.add_child(top_bar)
	toolbar_vbox.add_child(_reputation_bar)
	_reputation_bar.custom_minimum_size.y = 10

	hud.add_child(toolbar)

	_score_label.add_theme_font_size_override("font_size", 15)
	_score_label.add_theme_color_override("font_color", XPTheme.TEXT_WHITE)
	_combo_label.add_theme_font_size_override("font_size", 13)
	_combo_label.add_theme_color_override("font_color", XPTheme.TEXT_WHITE)
	_day_label.add_theme_font_size_override("font_size", 13)
	_day_label.add_theme_color_override("font_color", XPTheme.TEXT_WHITE)


func _setup_desktop_icons() -> void:
	var icons_data := [
		{"name": "My Computer", "type": DesktopIconScript.IconType.MY_COMPUTER, "pos": Vector2(16, 70)},
		{"name": "My Documents", "type": DesktopIconScript.IconType.MY_DOCUMENTS, "pos": Vector2(16, 160)},
		{"name": "Recycle Bin", "type": DesktopIconScript.IconType.RECYCLE_BIN, "pos": Vector2(16, 250)},
		{"name": "Internet\nExplorer", "type": DesktopIconScript.IconType.INTERNET_EXPLORER, "pos": Vector2(16, 340)},
		{"name": "Control\nPanel", "type": DesktopIconScript.IconType.CONTROL_PANEL, "pos": Vector2(16, 430)},
	]
	for icon_info: Dictionary in icons_data:
		var icon_container := VBoxContainer.new()
		icon_container.position = icon_info["pos"]
		icon_container.alignment = BoxContainer.ALIGNMENT_CENTER
		icon_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var icon := DesktopIconScript.new()
		icon.icon_type = icon_info["type"] as DesktopIconScript.IconType
		icon_container.add_child(icon)

		var name_label := Label.new()
		name_label.text = icon_info["name"]
		name_label.add_theme_color_override("font_color", XPTheme.TEXT_WHITE)
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_constant_override("outline_size", 3)
		name_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.7))
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_container.add_child(name_label)

		_background.add_child(icon_container)


func _setup_popup_container() -> void:
	_popup_container = Control.new()
	_popup_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_popup_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_popup_container)


func _setup_taskbar() -> void:
	_taskbar_buttons.clear()
	for i in range(MAX_SLOTS):
		var btn: Button = TaskbarButtonScript.new()
		btn.setup(i)
		_task_slots_container.add_child(btn)
		btn.pressed.connect(_on_taskbar_button_pressed.bind(i))
		_taskbar_buttons.append(btn)


func _connect_signals() -> void:
	EventBus.task_spawned.connect(_on_task_spawned)
	EventBus.task_completed.connect(_on_task_completed)
	EventBus.task_failed.connect(_on_task_failed)
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.reputation_changed.connect(_on_reputation_changed)
	EventBus.combo_changed.connect(_on_combo_changed)
	EventBus.day_started.connect(_on_day_started)
	EventBus.show_day_summary.connect(_on_show_day_summary)
	EventBus.game_over.connect(_on_game_over)


func _select_slot(slot: int) -> void:
	if slot < 0 or slot >= MAX_SLOTS:
		return

	# Deselect previous
	if _selected_slot >= 0 and _selected_slot < _taskbar_buttons.size():
		_taskbar_buttons[_selected_slot].set_selected(false)
		if _task_windows.has(_selected_slot):
			_task_windows[_selected_slot].visible = false

	# If same slot, deselect (toggle)
	if _selected_slot == slot:
		_selected_slot = -1
		return

	_selected_slot = slot
	_taskbar_buttons[slot].set_selected(true)

	# Show or create the task window
	var task_data = TaskManager.get_slot_data(slot)
	if task_data == null:
		_selected_slot = -1
		_taskbar_buttons[slot].set_selected(false)
		return

	if not _task_windows.has(slot):
		_create_task_window(slot, task_data)
	else:
		_task_windows[slot].visible = true

	EventBus.task_activated.emit(slot)


func _create_task_window(slot: int, task_data: Resource) -> void:
	var tw = TaskWindowScript.new()
	_task_window_container.add_child(tw)
	tw.initialize(task_data, slot)

	tw.task_completed.connect(_on_task_window_completed.bind(slot))
	tw.task_failed.connect(_on_task_window_failed.bind(slot))
	tw.mistake_made.connect(_on_task_window_mistake.bind(slot))

	_task_windows[slot] = tw


func _remove_task_window(slot: int) -> void:
	if _task_windows.has(slot):
		_task_windows[slot].queue_free()
		_task_windows.erase(slot)
	if _selected_slot == slot:
		_selected_slot = -1


func _update_clock() -> void:
	var remaining: float = TaskManager.get_day_time_remaining()
	var total_seconds: int = int(remaining)
	@warning_ignore("integer_division")
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	_clock_label.text = "%d:%02d" % [minutes, seconds]


func _update_patience_bars() -> void:
	for i in range(MAX_SLOTS):
		var ratio: float = TaskManager.get_slot_patience_ratio(i)
		_taskbar_buttons[i].update_patience(ratio)


# --- Signal handlers ---

func _on_taskbar_button_pressed(slot: int) -> void:
	_select_slot(slot)


func _on_task_spawned(slot: int, task_data: Resource) -> void:
	if slot >= 0 and slot < _taskbar_buttons.size():
		_taskbar_buttons[slot].assign_task(task_data)


func _on_task_completed(slot: int, _task_data: Resource, _perfect: bool) -> void:
	_remove_task_window(slot)
	if slot >= 0 and slot < _taskbar_buttons.size():
		_taskbar_buttons[slot].clear_task()


func _on_task_failed(slot: int, _task_data: Resource) -> void:
	if _task_windows.has(slot):
		_task_windows[slot].deactivate()
	_remove_task_window(slot)
	if slot >= 0 and slot < _taskbar_buttons.size():
		_taskbar_buttons[slot].clear_task()


func _on_task_window_completed(perfect: bool, slot: int) -> void:
	TaskManager.complete_slot(slot, perfect)


func _on_task_window_failed(slot: int) -> void:
	TaskManager.fail_slot(slot)


func _on_task_window_mistake(slot: int) -> void:
	EventBus.task_mistake.emit(slot)


func _on_score_changed(new_score: int) -> void:
	var gained: int = new_score - _prev_score
	_prev_score = new_score
	_score_label.text = "Score: %d" % new_score

	if gained > 0:
		_spawn_score_popup(gained)


func _on_reputation_changed(new_reputation: float) -> void:
	_reputation_bar.value = new_reputation

	# Flash reputation bar red if low
	if new_reputation <= 25.0:
		var bar_style: StyleBoxFlat = _reputation_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
		bar_style.bg_color = XPTheme.ERROR_RED
		_reputation_bar.add_theme_stylebox_override("fill", bar_style)
	elif new_reputation <= 40.0:
		var bar_style: StyleBoxFlat = _reputation_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
		bar_style.bg_color = XPTheme.WARNING_YELLOW
		_reputation_bar.add_theme_stylebox_override("fill", bar_style)
	else:
		var bar_style: StyleBoxFlat = _reputation_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
		bar_style.bg_color = XPTheme.PROGRESS_GREEN
		_reputation_bar.add_theme_stylebox_override("fill", bar_style)


func _on_combo_changed(new_combo: int) -> void:
	if new_combo > 1:
		_combo_label.text = "Combo x%d" % new_combo
		_combo_label.visible = true
		# Animate combo label with a scale pulse
		var tween := create_tween()
		_combo_label.scale = Vector2(1.3, 1.3)
		tween.tween_property(_combo_label, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	else:
		_combo_label.visible = false


func _spawn_score_popup(points: int) -> void:
	var color := Color(1.0, 1.0, 0.4)  # Yellow gold
	if points >= 200:
		color = Color(1.0, 0.85, 0.0)  # Bright gold for big scores
	var popup := ScorePopupScript.create("+%d" % points, color, 22)
	# Position near the score label
	popup.position = _score_label.global_position + Vector2(-60, 10)
	popup.position.x += randf_range(-20, 20)
	_popup_container.add_child(popup)


func _on_day_started(day_number: int) -> void:
	_day_label.text = "Day %d" % day_number
	_score_label.text = "Score: %d" % GameManager.score
	_prev_score = GameManager.score
	_reputation_bar.value = GameManager.reputation


func _on_show_day_summary(_stats: Dictionary) -> void:
	get_tree().change_scene_to_file("res://scenes/day_summary.tscn")


func _on_game_over() -> void:
	# Brief delay before showing BSOD game over screen
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
