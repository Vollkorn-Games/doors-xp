extends Control

## Draws a small Windows XP flag logo (4 colored squares in a 2x2 grid).
## Reusable across login screen and start button.

const FLAG_RED := Color(0.90, 0.20, 0.15)
const FLAG_GREEN := Color(0.20, 0.70, 0.20)
const FLAG_BLUE := Color(0.15, 0.40, 0.85)
const FLAG_YELLOW := Color(0.95, 0.75, 0.10)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var s := minf(size.x, size.y)
	var half := s / 2.0 - 1.0
	var gap := 1.5
	var ox := (size.x - s) / 2.0
	var oy := (size.y - s) / 2.0

	draw_rect(Rect2(ox, oy, half, half), FLAG_RED)
	draw_rect(Rect2(ox + half + gap, oy, half, half), FLAG_GREEN)
	draw_rect(Rect2(ox, oy + half + gap, half, half), FLAG_BLUE)
	draw_rect(Rect2(ox + half + gap, oy + half + gap, half, half), FLAG_YELLOW)
