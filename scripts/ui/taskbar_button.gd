class_name TaskbarButton
extends Button

## Individual task slot button in the XP-style taskbar.
## Shows task name, slot number, and a patience bar that shrinks over time.
## Tinted with the task's color for visual identity.

const _XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")

var slot_index: int = 0
var _task_data: Resource  # TaskData
var _patience_ratio: float = 1.0
var _is_occupied: bool = false
var _is_selected: bool = false
var _task_color: Color = Color.TRANSPARENT

var _normal_style: StyleBoxFlat
var _selected_style: StyleBoxFlat
var _empty_style: StyleBoxFlat


func _ready() -> void:
	_ensure_styles()
	custom_minimum_size = Vector2(100, 28)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_text = true
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

	add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	add_theme_color_override("font_hover_color", _XPTheme.TEXT_WHITE)
	add_theme_color_override("font_pressed_color", _XPTheme.TEXT_WHITE)
	add_theme_font_size_override("font_size", 11)

	_update_style()


func setup(index: int) -> void:
	slot_index = index
	text = "%d" % (index + 1)
	_ensure_styles()
	_update_style()


func assign_task(task_data: Resource) -> void:
	_task_data = task_data
	_is_occupied = true
	_patience_ratio = 1.0
	_task_color = task_data.task_color
	text = "%d %s" % [slot_index + 1, task_data.task_name]
	_rebuild_task_styles()
	_update_style()


func clear_task() -> void:
	_task_data = null
	_is_occupied = false
	_is_selected = false
	_patience_ratio = 1.0
	_task_color = Color.TRANSPARENT
	text = "%d" % (slot_index + 1)
	_update_style()


func set_selected(selected: bool) -> void:
	_is_selected = selected
	_update_style()


func update_patience(ratio: float) -> void:
	_patience_ratio = clampf(ratio, 0.0, 1.0)
	queue_redraw()


func _ensure_styles() -> void:
	if _normal_style == null:
		_normal_style = _XPTheme.make_taskbar_button_normal()
		_selected_style = _XPTheme.make_taskbar_button_selected()
		_empty_style = _XPTheme.make_taskbar_button_empty()


func _rebuild_task_styles() -> void:
	# Blend the task color into the taskbar button for a subtle tint
	var base_normal := _XPTheme.make_taskbar_button_normal()
	base_normal.bg_color = base_normal.bg_color.lerp(_task_color, 0.35)
	base_normal.border_color = base_normal.border_color.lerp(_task_color, 0.25)
	_normal_style = base_normal

	var base_selected := _XPTheme.make_taskbar_button_selected()
	base_selected.bg_color = base_selected.bg_color.lerp(_task_color, 0.4)
	base_selected.border_color = base_selected.border_color.lerp(_task_color, 0.3)
	_selected_style = base_selected


func _update_style() -> void:
	if _empty_style == null:
		return
	if not _is_occupied:
		add_theme_stylebox_override("normal", _empty_style)
		add_theme_stylebox_override("hover", _empty_style)
		add_theme_stylebox_override("pressed", _empty_style)
	elif _is_selected:
		add_theme_stylebox_override("normal", _selected_style)
		add_theme_stylebox_override("hover", _selected_style)
		add_theme_stylebox_override("pressed", _selected_style)
	else:
		add_theme_stylebox_override("normal", _normal_style)
		add_theme_stylebox_override("hover", _selected_style)
		add_theme_stylebox_override("pressed", _normal_style)


func _draw() -> void:
	if not _is_occupied:
		return
	# Draw patience bar at bottom of button
	var bar_height := 3.0
	var bar_width: float = size.x * _patience_ratio
	var color := Color.GREEN_YELLOW
	if _patience_ratio <= 0.25:
		color = _XPTheme.ERROR_RED
	elif _patience_ratio <= 0.5:
		color = _XPTheme.WARNING_YELLOW
	draw_rect(Rect2(0.0, size.y - bar_height, bar_width, bar_height), color)
