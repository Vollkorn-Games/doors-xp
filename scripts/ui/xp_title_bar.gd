extends Control

## Draws an authentic Windows XP title bar gradient.
## Real XP: dark blue edges, bright blue-white center glow, subtle vertical darkening.

var base_color: Color = Color(0.0, 0.34, 0.84)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	# Derive color stops from the base_color
	var dark := base_color.darkened(0.4)
	var bright := base_color.lightened(0.55)
	var top_highlight := base_color.lightened(0.65)

	# Top highlight line (1px bright)
	draw_rect(Rect2(0, 0, w, 1), top_highlight)

	# Draw the gradient using many horizontal bands for smoothness
	var h_bands := 48
	var v_bands := 6
	for j in range(v_bands):
		var vt := float(j) / v_bands
		var v_next := float(j + 1) / v_bands
		var y := 1.0 + vt * (h - 1.0)
		var band_h := (v_next - vt) * (h - 1.0) + 1.0

		# Vertical: top brighter, bottom darker (XP gradient is brighter at top)
		var v_darken := vt * 0.3

		for i in range(h_bands):
			var ht := float(i) / h_bands
			var h_next := float(i + 1) / h_bands
			var x := ht * w
			var band_w := (h_next - ht) * w + 1.0

			# Horizontal: bright center peak at ~40%, dark at edges
			# XP uses a gaussian-like bright spot in the center
			var center_dist: float = absf(ht - 0.4) * 2.5
			var h_factor := 1.0 - clampf(center_dist, 0.0, 1.0)
			# Smooth curve (ease in-out)
			h_factor = h_factor * h_factor * (3.0 - 2.0 * h_factor)

			# Blend from dark edges to bright center
			var color := dark.lerp(bright, h_factor)
			# Apply vertical darkening
			color = color.darkened(v_darken)
			draw_rect(Rect2(x, y, band_w, band_h), color)

	# Bottom edge: subtle dark line for definition
	draw_rect(Rect2(0, h - 1, w, 1), dark.darkened(0.15))
