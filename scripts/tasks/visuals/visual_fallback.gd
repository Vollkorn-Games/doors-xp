extends "res://scripts/tasks/task_visual.gd"

## Generic fallback visual for tasks without a custom visual.
## Shows the step label and description in a simple XP dialog style.

var _step_label: String = ""
var _step_description: String = ""
var _step_count: int = 0


func set_step(index: int) -> void:
	super.set_step(index)


func set_task_info(step_label: String, step_description: String, step_count: int) -> void:
	_step_label = step_label
	_step_description = step_description
	_step_count = step_count
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	# Background
	draw_rect(Rect2(0, 0, w, h), Color(0.93, 0.92, 0.87))

	# Draw a centered icon area
	var icon_y := h * 0.3
	# Generic monitor/computer icon
	var cx := w / 2.0
	var monitor := Rect2(cx - 24, icon_y - 20, 48, 34)
	draw_rect(monitor, Color(0.75, 0.75, 0.72))
	draw_rect(monitor, Color(0.4, 0.4, 0.38), false, 2.0)
	var screen := Rect2(cx - 20, icon_y - 17, 40, 26)
	draw_rect(screen, Color(0.12, 0.35, 0.70))
	# Stand
	draw_rect(Rect2(cx - 8, icon_y + 14, 16, 4), Color(0.6, 0.6, 0.57))
	draw_rect(Rect2(cx - 12, icon_y + 18, 24, 3), Color(0.55, 0.55, 0.52))

	# Step label
	if _step_label != "":
		_draw_centered_text(_step_label, Vector2(cx, icon_y + 42), 16, Color(0.0, 0.0, 0.0))

	# Step description
	if _step_description != "":
		_draw_centered_text(_step_description, Vector2(cx, icon_y + 62), 11, Color(0.45, 0.45, 0.42))

	# If waiting, show a progress bar
	if _is_waiting:
		var bar_w := w * 0.6
		var bar_rect := Rect2(cx - bar_w / 2.0, icon_y + 80, bar_w, 16)
		_draw_progress_bar(bar_rect, _wait_progress)
		_draw_centered_text("Please wait...", Vector2(cx, icon_y + 110), 10, Color(0.4, 0.4, 0.4))
