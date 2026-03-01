class_name TaskWindow
extends PanelContainer

## Displays a task's steps and handles key input for step progression.
## This is the core gameplay widget - equivalent to a prep station in CSD.

const _XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")
const _XPTitleBar := preload("res://scripts/ui/xp_title_bar.gd")

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

var _title_bar: PanelContainer
var _title_bar_gradient: Control  # XPTitleBar instance
var _title_label: Label
var _progress_label: Label
var _steps_container: VBoxContainer
var _step_labels: Array[Label] = []
var _current_step_panel: PanelContainer
var _key_hint_label: Label
var _step_action_label: Label
var _step_desc_label: Label
var _patience_bar: ProgressBar
var _wait_timer: Timer
var _mistake_label: Label
var _flash_tween: Tween

# Step indicator characters
const CHECK := "  "
const ARROW := "  "
const EMPTY := "    "


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

	# Apply task-specific color to title bar and window border
	_apply_task_color()

	_build_steps_display()
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

func _apply_task_color() -> void:
	# Title bar gradient uses the task color
	if _title_bar_gradient:
		_title_bar_gradient.base_color = _task_color
		_title_bar_gradient.queue_redraw()

	# Window border tinted to match (semi-transparent blend)
	var body_style := _XPTheme.make_window_body_style()
	body_style.border_color = Color(_task_color, 0.5)
	add_theme_stylebox_override("panel", body_style)

	# Key hint label colored to match
	_key_hint_label.add_theme_color_override("font_color", _task_color)


func _advance_step() -> void:
	_mark_step_complete(_current_step_index)
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
	_key_hint_label.text = "[...]"
	_step_action_label.text = _task_data.steps[_current_step_index].label
	_step_desc_label.text = _task_data.steps[_current_step_index].description
	_highlight_current_step()
	_wait_timer.wait_time = duration
	_wait_timer.start()


func _on_wait_timer_timeout() -> void:
	_is_waiting = false
	_advance_step()


func _on_mistake() -> void:
	_mistakes += 1
	mistake_made.emit()
	_mistake_label.text = "Mistakes: %d / %d" % [_mistakes, _task_data.max_mistakes]
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
	var body_style: StyleBoxFlat = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	body_style.bg_color = flash_color
	add_theme_stylebox_override("panel", body_style)
	_key_hint_label.text = "DONE!" if not perfect else "PERFECT!"
	_step_action_label.text = ""
	_step_desc_label.text = ""


func _flash_error() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_flash_tween = create_tween()
	var original_color: Color = _XPTheme.WINDOW_BG
	var body_style: StyleBoxFlat = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	body_style.bg_color = Color(1.0, 0.7, 0.7)
	add_theme_stylebox_override("panel", body_style)
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
	_step_desc_label.text = step.description
	_progress_label.text = "Step %d/%d" % [_current_step_index + 1, _task_data.steps.size()]
	_highlight_current_step()


func _mark_step_complete(index: int) -> void:
	if index < _step_labels.size():
		_step_labels[index].text = CHECK + _task_data.steps[index].label
		_step_labels[index].add_theme_color_override("font_color", Color(0.4, 0.6, 0.3))


func _highlight_current_step() -> void:
	for i in range(_step_labels.size()):
		if i < _current_step_index:
			continue # Already marked complete
		elif i == _current_step_index:
			_step_labels[i].text = ARROW + _task_data.steps[i].label
			_step_labels[i].add_theme_color_override("font_color", _task_color)
			_step_labels[i].add_theme_font_size_override("font_size", 14)
		else:
			_step_labels[i].text = EMPTY + _task_data.steps[i].label
			_step_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))


func _build_steps_display() -> void:
	for child in _steps_container.get_children():
		child.queue_free()
	_step_labels.clear()

	for i in range(_task_data.steps.size()):
		var lbl := Label.new()
		lbl.text = EMPTY + _task_data.steps[i].label
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		lbl.add_theme_font_size_override("font_size", 13)
		_steps_container.add_child(lbl)
		_step_labels.append(lbl)


func _build_ui() -> void:
	custom_minimum_size = Vector2(400, 300)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER

	add_theme_stylebox_override("panel", _XPTheme.make_window_body_style())

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	# Title bar: MarginContainer with gradient drawn behind content
	_title_bar = PanelContainer.new()
	var title_bar_style := StyleBoxFlat.new()
	title_bar_style.bg_color = _XPTheme.TITLE_BAR_BLUE  # Fallback color
	title_bar_style.corner_radius_top_left = 8
	title_bar_style.corner_radius_top_right = 8
	title_bar_style.content_margin_left = 8.0
	title_bar_style.content_margin_right = 4.0
	title_bar_style.content_margin_top = 4.0
	title_bar_style.content_margin_bottom = 4.0
	_title_bar.add_theme_stylebox_override("panel", title_bar_style)
	vbox.add_child(_title_bar)

	var title_hbox := HBoxContainer.new()
	title_hbox.add_theme_constant_override("separation", 4)
	_title_bar.add_child(title_hbox)

	# Gradient overlay drawn on top of the PanelContainer background
	_title_bar_gradient = _XPTitleBar.new()
	_title_bar_gradient.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_title_bar_gradient.show_behind_parent = true
	_title_bar.add_child(_title_bar_gradient)

	_title_label = Label.new()
	_title_label.text = "Task"
	_title_label.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	_title_label.add_theme_font_size_override("font_size", 14)
	_title_label.add_theme_constant_override("outline_size", 1)
	_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.3))
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_hbox.add_child(_title_label)

	_progress_label = Label.new()
	_progress_label.text = ""
	_progress_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	_progress_label.add_theme_font_size_override("font_size", 11)
	_progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_hbox.add_child(_progress_label)

	# Window control buttons (decorative, XP-style with 3D bevel)
	var ctrl_spacing := HBoxContainer.new()
	ctrl_spacing.add_theme_constant_override("separation", 2)
	ctrl_spacing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_hbox.add_child(ctrl_spacing)
	for btn_info: Array in [
		["_", Color(0.22, 0.45, 0.88), Color(0.35, 0.60, 1.0)],
		["[]", Color(0.22, 0.45, 0.88), Color(0.35, 0.60, 1.0)],
		["X", Color(0.78, 0.20, 0.15), Color(0.95, 0.40, 0.35)],
	]:
		var ctrl_panel := PanelContainer.new()
		var ctrl_style := StyleBoxFlat.new()
		ctrl_style.bg_color = btn_info[1]
		# 3D bevel: lighter top/left border
		ctrl_style.border_color = btn_info[2]
		ctrl_style.border_width_top = 1
		ctrl_style.border_width_left = 1
		ctrl_style.border_width_bottom = 1
		ctrl_style.border_width_right = 1
		ctrl_style.set_corner_radius_all(2)
		ctrl_style.content_margin_left = 5.0
		ctrl_style.content_margin_right = 5.0
		ctrl_style.content_margin_top = 1.0
		ctrl_style.content_margin_bottom = 1.0
		ctrl_panel.add_theme_stylebox_override("panel", ctrl_style)
		ctrl_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ctrl_btn := Label.new()
		ctrl_btn.text = btn_info[0]
		ctrl_btn.add_theme_font_size_override("font_size", 9)
		ctrl_btn.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
		ctrl_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ctrl_panel.add_child(ctrl_btn)
		ctrl_spacing.add_child(ctrl_panel)

	# Steps list
	_steps_container = VBoxContainer.new()
	_steps_container.add_theme_constant_override("separation", 4)
	vbox.add_child(_steps_container)

	# Separator
	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Current step panel
	_current_step_panel = PanelContainer.new()
	var step_style := StyleBoxFlat.new()
	step_style.bg_color = Color(0.95, 0.95, 0.92)
	step_style.border_color = Color(0.7, 0.7, 0.65)
	step_style.set_border_width_all(1)
	step_style.content_margin_left = 12.0
	step_style.content_margin_right = 12.0
	step_style.content_margin_top = 10.0
	step_style.content_margin_bottom = 10.0
	_current_step_panel.add_theme_stylebox_override("panel", step_style)
	vbox.add_child(_current_step_panel)

	var step_vbox := VBoxContainer.new()
	step_vbox.add_theme_constant_override("separation", 4)
	_current_step_panel.add_child(step_vbox)

	var step_hbox := HBoxContainer.new()
	step_hbox.add_theme_constant_override("separation", 12)
	step_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	step_vbox.add_child(step_hbox)

	_key_hint_label = Label.new()
	_key_hint_label.text = "[?]"
	_key_hint_label.add_theme_font_size_override("font_size", 24)
	_key_hint_label.add_theme_color_override("font_color", _XPTheme.TITLE_BAR_BLUE)
	step_hbox.add_child(_key_hint_label)

	_step_action_label = Label.new()
	_step_action_label.text = "..."
	_step_action_label.add_theme_font_size_override("font_size", 18)
	step_hbox.add_child(_step_action_label)

	# Step description label (flavor text)
	_step_desc_label = Label.new()
	_step_desc_label.text = ""
	_step_desc_label.add_theme_font_size_override("font_size", 11)
	_step_desc_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.42))
	_step_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_vbox.add_child(_step_desc_label)

	# Mistake label
	_mistake_label = Label.new()
	_mistake_label.text = ""
	_mistake_label.add_theme_font_size_override("font_size", 11)
	_mistake_label.add_theme_color_override("font_color", _XPTheme.ERROR_RED)
	_mistake_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(_mistake_label)

	# Patience bar
	_patience_bar = ProgressBar.new()
	_patience_bar.custom_minimum_size.y = 12
	_patience_bar.show_percentage = false
	vbox.add_child(_patience_bar)

	# Wait timer
	_wait_timer = Timer.new()
	_wait_timer.one_shot = true
	_wait_timer.timeout.connect(_on_wait_timer_timeout)
	add_child(_wait_timer)


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
