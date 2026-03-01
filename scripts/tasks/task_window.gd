class_name TaskWindow
extends PanelContainer

## Displays a task's visual content and handles key input for step progression.
## This is the core gameplay widget — equivalent to a prep station in CSD.
##
## Frame structure mirrors authentic Windows XP:
##   TaskWindow (PanelContainer - blue outer frame with rounded corners + shadow)
##     VBoxContainer
##       Title bar (gradient, control buttons)
##       Body panel (beige interior)
##         Menu bar
##         Sunken visual content area
##         Step display + patience bar

const _XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")
const _XPTitleBar := preload("res://scripts/ui/xp_title_bar.gd")
const _FallbackVisual := preload("res://scripts/tasks/visuals/visual_fallback.gd")

# Visual scripts mapped by task_id
const _Visuals := {
	&"print_document": preload("res://scripts/tasks/visuals/visual_print_document.gd"),
	&"read_email": preload("res://scripts/tasks/visuals/visual_read_email.gd"),
	&"virus_alert": preload("res://scripts/tasks/visuals/visual_virus_alert.gd"),
	&"organize_files": preload("res://scripts/tasks/visuals/visual_organize_files.gd"),
	&"install_software": preload("res://scripts/tasks/visuals/visual_install_software.gd"),
	&"defrag_hdd": preload("res://scripts/tasks/visuals/visual_defrag_hdd.gd"),
	&"blue_screen_fix": preload("res://scripts/tasks/visuals/visual_blue_screen_fix.gd"),
}

signal step_completed(step_index: int)
signal task_completed(perfect: bool)
signal task_failed()
signal mistake_made()

var _task_data: Resource  # TaskData
var _slot_index: int = -1
var _current_step_index: int = 0
var _mistakes: int = 0
var _is_active: bool = false
var _is_waiting: bool = false
var _task_color: Color = _XPTheme.TITLE_BAR_BLUE

# Wait progress tracking
var _wait_start_time: float = 0.0
var _wait_duration: float = 0.0

var _title_bar: PanelContainer
var _title_bar_gradient: Control  # XPTitleBar instance
var _title_label: Label
var _progress_label: Label
var _body_panel: PanelContainer  # Inner beige body
var _visual_container: PanelContainer
var _visual: Control  # TaskVisual instance
var _key_hint_label: Label
var _step_action_label: Label
var _mistake_label: Label
var _patience_bar: ProgressBar
var _wait_timer: Timer
var _flash_tween: Tween


func _ready() -> void:
	_build_ui()


func initialize(task_data: Resource, slot_index: int = -1) -> void:
	_task_data = task_data
	_slot_index = slot_index
	_current_step_index = 0
	_mistakes = 0
	_is_active = true
	_is_waiting = false
	_task_color = task_data.task_color

	_title_label.text = task_data.task_name
	_patience_bar.max_value = 1.0
	_patience_bar.value = 1.0
	_mistake_label.text = ""

	# Apply task-specific color to title bar and window frame
	_apply_task_color()

	# Create the visual for this task
	_create_visual(task_data)

	_show_current_step()


func _process(_delta: float) -> void:
	if not _is_active:
		return

	# Read time from TaskManager (single source of truth)
	var ratio: float = 1.0
	if _slot_index >= 0:
		ratio = TaskManager.get_slot_patience_ratio(_slot_index)
	_patience_bar.value = ratio

	# Update patience bar color
	var fill_style: StyleBoxFlat = _patience_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	if ratio <= 0.25:
		fill_style.bg_color = _XPTheme.ERROR_RED
	elif ratio <= 0.5:
		fill_style.bg_color = _XPTheme.WARNING_YELLOW
	else:
		fill_style.bg_color = _XPTheme.PROGRESS_GREEN
	_patience_bar.add_theme_stylebox_override("fill", fill_style)

	# Update wait progress for visual
	if _is_waiting and _wait_duration > 0.0 and _visual:
		var elapsed := (Time.get_ticks_msec() / 1000.0) - _wait_start_time
		var progress := clampf(elapsed / _wait_duration, 0.0, 1.0)
		_visual.set_wait_progress(progress)


func handle_key_input(event: InputEventKey) -> void:
	if not _is_active or _is_waiting:
		return

	var current_step = _task_data.steps[_current_step_index]
	var expected: String = current_step.key_action.to_lower()
	var pressed: String = _keycode_to_string(event.keycode)

	if pressed == expected:
		_advance_step()
	else:
		_on_mistake()


func is_active() -> bool:
	return _is_active


# --- Internal ---

func _create_visual(task_data: Resource) -> void:
	# Remove old visual if any
	if _visual:
		_visual.queue_free()
		_visual = null

	var visual_script: GDScript = _Visuals.get(task_data.task_id, _FallbackVisual)
	_visual = visual_script.new()
	_visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_visual_container.add_child(_visual)


func _apply_task_color() -> void:
	# Title bar gradient uses the task color
	if _title_bar_gradient:
		_title_bar_gradient.base_color = _task_color
		_title_bar_gradient.queue_redraw()

	# Outer frame tinted to match the task color
	var frame_style := _XPTheme.make_window_frame_style(_task_color)
	add_theme_stylebox_override("panel", frame_style)

	# Key hint label colored to match
	_key_hint_label.add_theme_color_override("font_color", _task_color)


func _advance_step() -> void:
	step_completed.emit(_current_step_index)
	_current_step_index += 1

	if _current_step_index >= _task_data.steps.size():
		_on_task_complete()
		return

	var next_step = _task_data.steps[_current_step_index]
	if next_step.is_timed_wait:
		_start_wait(next_step.wait_time)
	else:
		_show_current_step()


func _start_wait(duration: float) -> void:
	_is_waiting = true
	_wait_start_time = Time.get_ticks_msec() / 1000.0
	_wait_duration = duration
	_key_hint_label.text = "[...]"
	var step = _task_data.steps[_current_step_index]
	_step_action_label.text = step.label
	_progress_label.text = "Step %d/%d" % [_current_step_index + 1, _task_data.steps.size()]

	# Update visual
	if _visual:
		_visual.set_step(_current_step_index)
		_visual.set_waiting(true)

	_wait_timer.wait_time = duration
	_wait_timer.start()


func _on_wait_timer_timeout() -> void:
	_is_waiting = false
	_advance_step()


func _on_mistake() -> void:
	_mistakes += 1
	mistake_made.emit()
	_mistake_label.text = "Mistakes: %d/%d" % [_mistakes, _task_data.max_mistakes]
	_flash_error()

	if _mistakes >= _task_data.max_mistakes:
		_on_task_fail()


func _on_task_complete() -> void:
	_is_active = false
	var perfect: bool = _mistakes == 0
	_flash_success(perfect)
	task_completed.emit(perfect)


func _on_task_fail() -> void:
	_is_active = false
	task_failed.emit()


func deactivate() -> void:
	_is_active = false


func _flash_success(perfect: bool) -> void:
	if _flash_tween:
		_flash_tween.kill()
		_flash_tween = null
	var flash_color := Color(0.7, 1.0, 0.7) if not perfect else Color(1.0, 1.0, 0.5)
	var body_style: StyleBoxFlat = _body_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	body_style.bg_color = flash_color
	_body_panel.add_theme_stylebox_override("panel", body_style)
	_key_hint_label.text = "DONE!" if not perfect else "PERFECT!"
	_step_action_label.text = ""


func _flash_error() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_flash_tween = create_tween()
	var original_color: Color = _XPTheme.WINDOW_BG
	var body_style: StyleBoxFlat = _body_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	body_style.bg_color = Color(1.0, 0.7, 0.7)
	_body_panel.add_theme_stylebox_override("panel", body_style)
	_flash_tween.tween_property(body_style, "bg_color", original_color, 0.3)


func _show_current_step() -> void:
	if _current_step_index >= _task_data.steps.size():
		return
	var step = _task_data.steps[_current_step_index]
	var key_display: String = step.key_action.to_upper()
	if key_display == "ENTER":
		key_display = "ENTER"
	elif key_display == "SPACE":
		key_display = "SPACE"
	_key_hint_label.text = "[%s]" % key_display
	_step_action_label.text = step.label
	_progress_label.text = "Step %d/%d" % [_current_step_index + 1, _task_data.steps.size()]

	# Update visual
	if _visual:
		_visual.set_step(_current_step_index)
		# Pass info to fallback visual if applicable
		if _visual.has_method(&"set_task_info"):
			_visual.set_task_info(step.label, step.description, _task_data.steps.size())


func _build_ui() -> void:
	custom_minimum_size = Vector2(420, 340)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# === Outer frame: blue rounded border with drop shadow ===
	# This wraps the entire window (title bar + body) as one unit,
	# matching the authentic XP window chrome.
	add_theme_stylebox_override("panel", _XPTheme.make_window_frame_style())

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_vbox)

	# === Title bar ===
	_build_title_bar(main_vbox)

	# === Inner body panel (beige, sits inside the blue frame) ===
	_body_panel = PanelContainer.new()
	_body_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_panel.add_theme_stylebox_override("panel", _XPTheme.make_window_inner_body_style())
	main_vbox.add_child(_body_panel)

	var body_vbox := VBoxContainer.new()
	body_vbox.add_theme_constant_override("separation", 0)
	_body_panel.add_child(body_vbox)

	# Menu bar
	_build_menu_bar(body_vbox)

	# Visual panel — fills most of the window, with sunken/inset look
	_visual_container = PanelContainer.new()
	_visual_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_visual_container.add_theme_stylebox_override("panel", _XPTheme.make_sunken_panel_style())
	body_vbox.add_child(_visual_container)

	# Separator
	var sep := HSeparator.new()
	body_vbox.add_child(sep)

	# Step display row: [KEY] Action
	_build_step_display(body_vbox)

	# Bottom row: Mistakes + patience bar
	_build_bottom_row(body_vbox)

	# Wait timer (non-visual, just add to tree)
	_wait_timer = Timer.new()
	_wait_timer.one_shot = true
	_wait_timer.timeout.connect(_on_wait_timer_timeout)
	add_child(_wait_timer)


func _build_title_bar(parent: VBoxContainer) -> void:
	_title_bar = PanelContainer.new()
	# Transparent background — the gradient draws behind
	var tb_style := StyleBoxFlat.new()
	tb_style.bg_color = Color(0, 0, 0, 0)
	tb_style.content_margin_left = 6.0
	tb_style.content_margin_right = 3.0
	tb_style.content_margin_top = 4.0
	tb_style.content_margin_bottom = 4.0
	_title_bar.add_theme_stylebox_override("panel", tb_style)
	_title_bar.custom_minimum_size.y = 32
	parent.add_child(_title_bar)

	# Gradient behind title bar content — extend into the frame padding
	# so the gradient fills the rounded top corners of the outer frame
	_title_bar_gradient = _XPTitleBar.new()
	_title_bar_gradient.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_title_bar_gradient.offset_left = -6.0
	_title_bar_gradient.offset_right = 3.0
	_title_bar_gradient.offset_top = -4.0
	_title_bar_gradient.show_behind_parent = true
	_title_bar.add_child(_title_bar_gradient)

	var title_hbox := HBoxContainer.new()
	title_hbox.add_theme_constant_override("separation", 6)
	title_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_title_bar.add_child(title_hbox)

	# Title text
	_title_label = Label.new()
	_title_label.text = "Task"
	_title_label.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	_title_label.add_theme_font_size_override("font_size", 14)
	_title_label.add_theme_constant_override("outline_size", 3)
	_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.4))
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_hbox.add_child(_title_label)

	# Step progress label
	_progress_label = Label.new()
	_progress_label.text = ""
	_progress_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_progress_label.add_theme_font_size_override("font_size", 11)
	_progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_hbox.add_child(_progress_label)

	# === Window control buttons (XP-authentic) ===
	_build_control_buttons(title_hbox)


func _build_control_buttons(parent: HBoxContainer) -> void:
	# XP groups min+max together, then a small gap, then close
	var btn_group := HBoxContainer.new()
	btn_group.add_theme_constant_override("separation", 0)
	btn_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(btn_group)

	# Minimize button (left of pair, rounded left corners only)
	var min_btn := _make_caption_button("_", false, true)
	btn_group.add_child(min_btn)

	# Maximize button (right of pair, rounded right corners only)
	var max_btn := _make_caption_button("\u25a1", false, false, true)
	btn_group.add_child(max_btn)

	# 2px gap before close
	var gap := Control.new()
	gap.custom_minimum_size.x = 2.0
	btn_group.add_child(gap)

	# Close button (fully rounded, red)
	var close_btn := _make_caption_button("\u00d7", true)
	btn_group.add_child(close_btn)


func _make_caption_button(icon_text: String, is_close: bool,
		round_left: bool = true, round_right: bool = true) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()

	if is_close:
		# Red close button
		style.bg_color = Color(0.83, 0.30, 0.22)
		style.border_color = Color(1.0, 0.55, 0.45)
		style.set_corner_radius_all(3)
	else:
		# Blue caption button (min/max)
		style.bg_color = Color(0.22, 0.50, 0.90)
		style.border_color = Color(0.45, 0.70, 1.0)
		# Pair buttons: only round the outer corners
		var radius_l := 3 if round_left else 0
		var radius_r := 3 if round_right else 0
		style.corner_radius_top_left = radius_l
		style.corner_radius_bottom_left = radius_l
		style.corner_radius_top_right = radius_r
		style.corner_radius_bottom_right = radius_r

	# XP bevel: lighter top/left border, darker bottom/right
	style.border_width_top = 1
	style.border_width_left = 1
	style.border_width_bottom = 1
	style.border_width_right = 1
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0

	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var label := Label.new()
	label.text = icon_text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.35))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(label)

	return panel


func _build_menu_bar(parent: VBoxContainer) -> void:
	var menu_bar := PanelContainer.new()
	var menu_style := StyleBoxFlat.new()
	menu_style.bg_color = _XPTheme.WINDOW_BG
	menu_style.border_color = Color(0.72, 0.72, 0.68)
	menu_style.border_width_bottom = 1
	menu_style.border_width_top = 0
	menu_style.border_width_left = 0
	menu_style.border_width_right = 0
	menu_style.content_margin_left = 6.0
	menu_style.content_margin_right = 6.0
	menu_style.content_margin_top = 3.0
	menu_style.content_margin_bottom = 3.0
	menu_bar.add_theme_stylebox_override("panel", menu_style)
	menu_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(menu_bar)

	var menu_hbox := HBoxContainer.new()
	menu_hbox.add_theme_constant_override("separation", 10)
	menu_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_bar.add_child(menu_hbox)

	for menu_text: String in ["File", "Edit", "View", "Help"]:
		var menu_label := Label.new()
		menu_label.text = menu_text
		menu_label.add_theme_font_size_override("font_size", 12)
		menu_label.add_theme_color_override("font_color", _XPTheme.TEXT_COLOR)
		menu_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		menu_hbox.add_child(menu_label)


func _build_step_display(parent: VBoxContainer) -> void:
	var step_margin := MarginContainer.new()
	step_margin.add_theme_constant_override("margin_left", 8)
	step_margin.add_theme_constant_override("margin_right", 8)
	step_margin.add_theme_constant_override("margin_top", 4)
	step_margin.add_theme_constant_override("margin_bottom", 2)
	parent.add_child(step_margin)

	var step_hbox := HBoxContainer.new()
	step_hbox.add_theme_constant_override("separation", 8)
	step_margin.add_child(step_hbox)

	_key_hint_label = Label.new()
	_key_hint_label.text = "[?]"
	_key_hint_label.add_theme_font_size_override("font_size", 20)
	_key_hint_label.add_theme_color_override("font_color", _XPTheme.TITLE_BAR_BLUE)
	step_hbox.add_child(_key_hint_label)

	_step_action_label = Label.new()
	_step_action_label.text = "..."
	_step_action_label.add_theme_font_size_override("font_size", 15)
	_step_action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	step_hbox.add_child(_step_action_label)


func _build_bottom_row(parent: VBoxContainer) -> void:
	var bottom_margin := MarginContainer.new()
	bottom_margin.add_theme_constant_override("margin_left", 8)
	bottom_margin.add_theme_constant_override("margin_right", 8)
	bottom_margin.add_theme_constant_override("margin_top", 0)
	bottom_margin.add_theme_constant_override("margin_bottom", 4)
	parent.add_child(bottom_margin)

	var bottom_hbox := HBoxContainer.new()
	bottom_hbox.add_theme_constant_override("separation", 8)
	bottom_margin.add_child(bottom_hbox)

	_mistake_label = Label.new()
	_mistake_label.text = ""
	_mistake_label.add_theme_font_size_override("font_size", 11)
	_mistake_label.add_theme_color_override("font_color", _XPTheme.ERROR_RED)
	bottom_hbox.add_child(_mistake_label)

	_patience_bar = ProgressBar.new()
	_patience_bar.custom_minimum_size = Vector2(0, 12)
	_patience_bar.show_percentage = false
	_patience_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_hbox.add_child(_patience_bar)


static func _keycode_to_string(keycode: Key) -> String:
	match keycode:
		KEY_A: return "a"
		KEY_B: return "b"
		KEY_C: return "c"
		KEY_D: return "d"
		KEY_E: return "e"
		KEY_F: return "f"
		KEY_G: return "g"
		KEY_H: return "h"
		KEY_I: return "i"
		KEY_J: return "j"
		KEY_K: return "k"
		KEY_L: return "l"
		KEY_M: return "m"
		KEY_N: return "n"
		KEY_O: return "o"
		KEY_P: return "p"
		KEY_Q: return "q"
		KEY_R: return "r"
		KEY_S: return "s"
		KEY_T: return "t"
		KEY_U: return "u"
		KEY_V: return "v"
		KEY_W: return "w"
		KEY_X: return "x"
		KEY_Y: return "y"
		KEY_Z: return "z"
		KEY_ENTER: return "enter"
		KEY_SPACE: return "space"
		KEY_ESCAPE: return "escape"
		KEY_TAB: return "tab"
		KEY_BACKSPACE: return "backspace"
		_: return ""
