extends Control

## Main gameplay scene - the Doors XP desktop.
## Manages task windows, taskbar, and routes keyboard input.

const XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")
const TaskWindowScript := preload("res://scripts/tasks/task_window.gd")
const TaskbarButtonScript := preload("res://scripts/ui/taskbar_button.gd")

const MAX_SLOTS := 8

var _taskbar_buttons: Array = []
var _task_windows: Dictionary = {}  # slot_index -> TaskWindow
var _selected_slot: int = -1

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
	_background.color = XPTheme.DESKTOP_BG
	_taskbar_panel.add_theme_stylebox_override("panel", XPTheme.make_taskbar_style())

	_start_button.add_theme_stylebox_override("normal", XPTheme.make_start_button_style())
	_start_button.add_theme_stylebox_override("hover", XPTheme.make_start_button_hover())
	_start_button.add_theme_stylebox_override("pressed", XPTheme.make_start_button_style())
	_start_button.add_theme_color_override("font_color", XPTheme.TEXT_WHITE)
	_start_button.add_theme_color_override("font_hover_color", XPTheme.TEXT_WHITE)
	_start_button.add_theme_font_size_override("font_size", 13)

	_clock_label.add_theme_color_override("font_color", XPTheme.TEXT_WHITE)
	_clock_label.add_theme_font_size_override("font_size", 12)

	_score_label.add_theme_font_size_override("font_size", 16)
	_combo_label.add_theme_font_size_override("font_size", 14)
	_day_label.add_theme_font_size_override("font_size", 14)


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
	_score_label.text = "Score: %d" % new_score


func _on_reputation_changed(new_reputation: float) -> void:
	_reputation_bar.value = new_reputation


func _on_combo_changed(new_combo: int) -> void:
	if new_combo > 1:
		_combo_label.text = "Combo x%d" % new_combo
		_combo_label.visible = true
	else:
		_combo_label.visible = false


func _on_day_started(day_number: int) -> void:
	_day_label.text = "Day %d" % day_number
	_score_label.text = "Score: %d" % GameManager.score
	_reputation_bar.value = GameManager.reputation


func _on_show_day_summary(_stats: Dictionary) -> void:
	get_tree().change_scene_to_file("res://scenes/day_summary.tscn")


func _on_game_over() -> void:
	# Brief delay before showing game over
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
