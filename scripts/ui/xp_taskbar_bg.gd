extends Control

## Draws the Windows XP taskbar gradient background.
## Bright highlight at top, lighter blue fading to darker blue at bottom.

# XP taskbar gradient stops
const TOP_HIGHLIGHT := Color(0.42, 0.65, 1.0)
const UPPER_BLUE := Color(0.22, 0.52, 0.95)
const MID_BLUE := Color(0.13, 0.38, 0.85)
const LOWER_BLUE := Color(0.08, 0.28, 0.70)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	# Bright highlight line at very top (2px)
	draw_rect(Rect2(0, 0, w, 2), TOP_HIGHLIGHT)

	# Gradient body below highlight
	var bands := 16
	var body_start := 2.0
	var body_h := h - body_start
	for i in range(bands):
		var t := float(i) / bands
		var next_t := float(i + 1) / bands
		var color: Color
		if t < 0.3:
			color = UPPER_BLUE.lerp(MID_BLUE, t / 0.3)
		else:
			color = MID_BLUE.lerp(LOWER_BLUE, (t - 0.3) / 0.7)
		var y := body_start + t * body_h
		var band_h := (next_t - t) * body_h + 1.0
		draw_rect(Rect2(0, y, w, band_h), color)
