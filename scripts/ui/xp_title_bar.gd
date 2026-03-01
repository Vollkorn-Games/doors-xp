extends Control

## Draws an authentic Windows XP title bar gradient.
## Darker at left/right edges, brighter in center, with a highlight line at top.

var base_color: Color = Color(0.0, 0.34, 0.84)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	var dark := base_color.darkened(0.25)
	var bright := base_color.lightened(0.3)

	# Top highlight (1px bright line)
	draw_rect(Rect2(0, 0, w, 1), bright.lightened(0.2))

	# Draw gradient using horizontal bands, each with horizontal color variation
	var v_bands := 8
	var h_bands := 24
	for j in range(v_bands):
		var vt := float(j) / v_bands
		var v_next := float(j + 1) / v_bands
		var y := 1.0 + vt * (h - 1.0)
		var band_h := (v_next - vt) * (h - 1.0) + 1.0

		# Vertical factor: top slightly brighter
		var v_factor := 1.0 - vt * 0.35

		for i in range(h_bands):
			var ht := float(i) / h_bands
			var h_next := float(i + 1) / h_bands
			var x := ht * w
			var band_w := (h_next - ht) * w + 1.0

			# Horizontal: peak brightness slightly left of center
			var center_dist: float = absf(ht - 0.42) * 2.2
			var h_factor := 1.0 - clampf(center_dist, 0.0, 1.0)
			h_factor *= h_factor  # Sharper falloff

			var color := dark.lerp(bright, h_factor * v_factor)
			draw_rect(Rect2(x, y, band_w, band_h), color)
