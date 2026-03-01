extends Control

## Base class for task-specific visual content drawn inside the task window.
## Subclasses override _draw() and use _step_index / _is_waiting / _wait_progress
## to render the appropriate XP application mock for each step.

var _step_index: int = -1
var _is_waiting: bool = false
var _wait_progress: float = 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_step(index: int) -> void:
	_step_index = index
	_is_waiting = false
	_wait_progress = 0.0
	queue_redraw()


func set_waiting(is_waiting: bool) -> void:
	_is_waiting = is_waiting
	_wait_progress = 0.0
	queue_redraw()


func set_wait_progress(progress: float) -> void:
	_wait_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


## Helper: draw a text string centered at a position.
func _draw_centered_text(text: String, pos: Vector2, font_size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(font, Vector2(pos.x - text_size.x / 2.0, pos.y + text_size.y / 4.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


## Helper: draw a text string left-aligned at a position.
func _draw_text(text: String, pos: Vector2, font_size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


## Helper: draw a simple XP-style button (raised rectangle with text).
func _draw_xp_button(rect: Rect2, text: String, highlighted: bool = false) -> void:
	var bg := Color(0.93, 0.92, 0.87) if not highlighted else Color(0.88, 0.92, 0.98)
	var border := Color(0.0, 0.24, 0.55) if not highlighted else Color(0.0, 0.4, 0.8)
	draw_rect(rect, bg)
	draw_rect(rect, border, false, 1.0)
	# Highlight top/left for 3D
	draw_line(Vector2(rect.position.x + 1, rect.position.y + 1), Vector2(rect.end.x - 1, rect.position.y + 1), Color(1.0, 1.0, 1.0, 0.6), 1.0)
	draw_line(Vector2(rect.position.x + 1, rect.position.y + 1), Vector2(rect.position.x + 1, rect.end.y - 1), Color(1.0, 1.0, 1.0, 0.6), 1.0)
	# Text
	_draw_centered_text(text, rect.get_center(), 11, Color(0.0, 0.0, 0.0))


## Helper: draw an XP-style progress bar.
func _draw_progress_bar(rect: Rect2, progress: float, bar_color: Color = Color(0.35, 0.68, 0.22)) -> void:
	# Background
	draw_rect(rect, Color(0.85, 0.85, 0.85))
	draw_rect(rect, Color(0.5, 0.5, 0.5), false, 1.0)
	# Fill - XP uses segmented blocks
	var inner := Rect2(rect.position.x + 2, rect.position.y + 2, (rect.size.x - 4) * progress, rect.size.y - 4)
	if inner.size.x > 0:
		# Draw as segments
		var seg_w := 8.0
		var seg_gap := 2.0
		var x := inner.position.x
		while x < inner.position.x + inner.size.x:
			var sw := minf(seg_w, inner.position.x + inner.size.x - x)
			draw_rect(Rect2(x, inner.position.y, sw, inner.size.y), bar_color)
			x += seg_w + seg_gap


## Helper: draw an XP-style inner window/panel area (sunken border).
func _draw_sunken_panel(rect: Rect2, bg_color: Color = Color(1.0, 1.0, 1.0)) -> void:
	draw_rect(rect, bg_color)
	# Sunken: dark top/left, light bottom/right
	draw_line(Vector2(rect.position.x, rect.position.y), Vector2(rect.end.x, rect.position.y), Color(0.5, 0.5, 0.48), 1.0)
	draw_line(Vector2(rect.position.x, rect.position.y), Vector2(rect.position.x, rect.end.y), Color(0.5, 0.5, 0.48), 1.0)
	draw_line(Vector2(rect.end.x, rect.position.y), Vector2(rect.end.x, rect.end.y), Color(1.0, 1.0, 1.0, 0.5), 1.0)
	draw_line(Vector2(rect.position.x, rect.end.y), Vector2(rect.end.x, rect.end.y), Color(1.0, 1.0, 1.0, 0.5), 1.0)


## Helper: draw a mini XP window (title bar + body) inside the visual panel.
func _draw_mini_window(rect: Rect2, title: String, title_color: Color = Color(0.0, 0.34, 0.84)) -> Rect2:
	# Title bar
	var tb_h := 18.0
	var tb_rect := Rect2(rect.position.x, rect.position.y, rect.size.x, tb_h)
	# Gradient
	var dark := title_color.darkened(0.3)
	var bright := title_color.lightened(0.4)
	var bands := 8
	for i in range(bands):
		var t := float(i) / bands
		var band_y := tb_rect.position.y + t * tb_h
		var band_h := tb_h / bands + 1.0
		var center_dist := absf(t - 0.4) * 2.5
		var factor := 1.0 - clampf(center_dist, 0.0, 1.0)
		var col := dark.lerp(bright, factor)
		draw_rect(Rect2(tb_rect.position.x, band_y, tb_rect.size.x, band_h), col)
	# Title text
	_draw_text(title, Vector2(tb_rect.position.x + 4, tb_rect.position.y + 13), 10, Color(1.0, 1.0, 1.0))
	# Close button
	var cb := Rect2(tb_rect.end.x - 16, tb_rect.position.y + 2, 14, 14)
	draw_rect(cb, Color(0.82, 0.22, 0.15))
	_draw_centered_text("X", cb.get_center(), 9, Color(1.0, 1.0, 1.0))
	# Body
	var body_rect := Rect2(rect.position.x, rect.position.y + tb_h, rect.size.x, rect.size.y - tb_h)
	draw_rect(body_rect, Color(0.93, 0.92, 0.87))
	draw_rect(rect, Color(0.0, 0.24, 0.55), false, 1.0)
	return body_rect
