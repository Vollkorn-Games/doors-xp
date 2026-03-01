extends Control

## Draws a simplified but recognizable Windows XP desktop icon using _draw().
## No background panel — icons sit directly on the wallpaper like real XP.

enum IconType { MY_COMPUTER, MY_DOCUMENTS, RECYCLE_BIN, INTERNET_EXPLORER, CONTROL_PANEL }

var icon_type: IconType = IconType.MY_COMPUTER

const ICON_SIZE := 40.0


func _init() -> void:
	custom_minimum_size = Vector2(48, 48)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var cx: float = size.x / 2.0
	var cy: float = size.y / 2.0
	match icon_type:
		IconType.MY_COMPUTER:
			_draw_my_computer(cx, cy)
		IconType.MY_DOCUMENTS:
			_draw_my_documents(cx, cy)
		IconType.RECYCLE_BIN:
			_draw_recycle_bin(cx, cy)
		IconType.INTERNET_EXPLORER:
			_draw_internet_explorer(cx, cy)
		IconType.CONTROL_PANEL:
			_draw_control_panel(cx, cy)


func _draw_my_computer(cx: float, cy: float) -> void:
	# Monitor body
	var monitor := Rect2(cx - 18, cy - 16, 36, 26)
	draw_rect(monitor, Color(0.75, 0.75, 0.72))  # Beige casing
	draw_rect(monitor, Color(0.4, 0.4, 0.38), false, 2.0)  # Dark border

	# Screen (inset)
	var screen := Rect2(cx - 14, cy - 13, 28, 19)
	draw_rect(screen, Color(0.12, 0.35, 0.70))  # Blue screen
	# Screen highlight
	draw_rect(Rect2(cx - 12, cy - 11, 12, 8), Color(0.20, 0.50, 0.85, 0.4))

	# Stand
	var stand_pts := PackedVector2Array([
		Vector2(cx - 6, cy + 10),
		Vector2(cx + 6, cy + 10),
		Vector2(cx + 4, cy + 15),
		Vector2(cx - 4, cy + 15),
	])
	draw_polygon(stand_pts, PackedColorArray([Color(0.65, 0.65, 0.62), Color(0.65, 0.65, 0.62), Color(0.55, 0.55, 0.52), Color(0.55, 0.55, 0.52)]))

	# Base
	draw_rect(Rect2(cx - 10, cy + 15, 20, 3), Color(0.6, 0.6, 0.57))
	draw_rect(Rect2(cx - 10, cy + 15, 20, 3), Color(0.4, 0.4, 0.38), false, 1.0)

	# Power LED
	draw_circle(Vector2(cx, cy + 8), 1.5, Color(0.3, 0.8, 0.3))

	# Windows logo on screen (tiny 2x2 flag)
	var fx := cx - 3.0
	var fy := cy - 5.0
	draw_rect(Rect2(fx, fy, 3, 3), Color(0.9, 0.2, 0.15))
	draw_rect(Rect2(fx + 4, fy, 3, 3), Color(0.2, 0.7, 0.2))
	draw_rect(Rect2(fx, fy + 4, 3, 3), Color(0.15, 0.4, 0.85))
	draw_rect(Rect2(fx + 4, fy + 4, 3, 3), Color(0.95, 0.75, 0.1))


func _draw_my_documents(cx: float, cy: float) -> void:
	# Folder back
	var back := Rect2(cx - 16, cy - 10, 32, 26)
	draw_rect(back, Color(0.82, 0.68, 0.22))  # Golden folder

	# Folder tab (top-left)
	var tab_pts := PackedVector2Array([
		Vector2(cx - 16, cy - 10),
		Vector2(cx - 16, cy - 15),
		Vector2(cx - 4, cy - 15),
		Vector2(cx - 2, cy - 10),
	])
	draw_polygon(tab_pts, PackedColorArray([Color(0.82, 0.68, 0.22), Color(0.88, 0.74, 0.28), Color(0.88, 0.74, 0.28), Color(0.82, 0.68, 0.22)]))

	# Folder front (slightly lighter, offset down)
	var front := Rect2(cx - 16, cy - 6, 32, 22)
	draw_rect(front, Color(0.92, 0.80, 0.35))
	draw_rect(front, Color(0.70, 0.58, 0.18), false, 1.0)

	# Document peeking out
	draw_rect(Rect2(cx - 6, cy - 12, 14, 18), Color(1.0, 1.0, 1.0, 0.85))
	draw_rect(Rect2(cx - 6, cy - 12, 14, 18), Color(0.5, 0.5, 0.5, 0.5), false, 1.0)
	# Text lines on document
	for i in range(4):
		var ly := cy - 8.0 + float(i) * 3.5
		draw_line(Vector2(cx - 3, ly), Vector2(cx + 5, ly), Color(0.4, 0.4, 0.4, 0.4), 1.0)


func _draw_recycle_bin(cx: float, cy: float) -> void:
	# Body (trapezoidal)
	var body_pts := PackedVector2Array([
		Vector2(cx - 12, cy - 6),
		Vector2(cx + 12, cy - 6),
		Vector2(cx + 10, cy + 16),
		Vector2(cx - 10, cy + 16),
	])
	var body_colors := PackedColorArray([
		Color(0.70, 0.72, 0.72),
		Color(0.70, 0.72, 0.72),
		Color(0.55, 0.57, 0.57),
		Color(0.55, 0.57, 0.57),
	])
	draw_polygon(body_pts, body_colors)
	# Body border
	draw_polyline(PackedVector2Array([
		Vector2(cx - 12, cy - 6), Vector2(cx + 12, cy - 6),
		Vector2(cx + 10, cy + 16), Vector2(cx - 10, cy + 16),
		Vector2(cx - 12, cy - 6),
	]), Color(0.35, 0.37, 0.37), 1.0)

	# Ridges (vertical lines)
	for i in range(3):
		var rx: float = cx - 6.0 + float(i) * 6.0
		var t: float = (rx - (cx - 12.0)) / 24.0
		var top_x: float = lerpf(cx - 12.0, cx + 12.0, t)
		var bot_x: float = lerpf(cx - 10.0, cx + 10.0, t)
		draw_line(Vector2(top_x, cy - 4), Vector2(bot_x, cy + 14), Color(0.45, 0.47, 0.47, 0.6), 1.0)

	# Lid
	draw_rect(Rect2(cx - 14, cy - 10, 28, 5), Color(0.65, 0.67, 0.67))
	draw_rect(Rect2(cx - 14, cy - 10, 28, 5), Color(0.4, 0.42, 0.42), false, 1.0)

	# Lid handle
	draw_rect(Rect2(cx - 4, cy - 14, 8, 5), Color(0.60, 0.62, 0.62))
	draw_rect(Rect2(cx - 4, cy - 14, 8, 5), Color(0.4, 0.42, 0.42), false, 1.0)

	# Recycling arrows (simplified: just a small green arrow symbol)
	draw_circle(Vector2(cx, cy + 4), 4, Color(0.25, 0.55, 0.25, 0.6))


func _draw_internet_explorer(cx: float, cy: float) -> void:
	# Blue circle background
	draw_circle(Vector2(cx, cy), 18, Color(0.10, 0.40, 0.82))
	draw_circle(Vector2(cx, cy), 18, Color(0.05, 0.25, 0.60), false, 1.5)

	# "e" shape — draw as a thick white arc + crossbar
	# Main body of the e (a nearly-complete circle)
	var e_radius := 11.0
	var e_center := Vector2(cx + 1, cy + 1)
	# Draw the e as an arc from roughly 30deg to 340deg
	var segments := 24
	var start_angle := deg_to_rad(40.0)
	var end_angle := deg_to_rad(350.0)
	var prev_pt := e_center + Vector2(cos(start_angle), sin(start_angle)) * e_radius
	for i in range(1, segments + 1):
		var t := float(i) / segments
		var angle := start_angle + t * (end_angle - start_angle)
		var pt := e_center + Vector2(cos(angle), sin(angle)) * e_radius
		draw_line(prev_pt, pt, Color(1.0, 1.0, 1.0, 0.9), 3.5)
		prev_pt = pt

	# Crossbar of the e
	draw_line(Vector2(cx - 9, cy + 1), Vector2(cx + 12, cy - 2), Color(1.0, 1.0, 1.0, 0.9), 3.0)

	# Orbital ring (angled arc going around the e)
	var ring_pts: PackedVector2Array = []
	var ring_colors: PackedColorArray = []
	for i in range(segments + 1):
		var t := float(i) / segments
		var angle := t * TAU
		var rx := 20.0
		var ry := 7.0
		var tilt := deg_to_rad(-30.0)
		var px := cos(angle) * rx
		var py := sin(angle) * ry
		var rotated_x := px * cos(tilt) - py * sin(tilt)
		var rotated_y := px * sin(tilt) + py * cos(tilt)
		ring_pts.append(Vector2(cx + rotated_x, cy + rotated_y))
		ring_colors.append(Color(0.95, 0.75, 0.10, 0.8))
	for i in range(ring_pts.size() - 1):
		draw_line(ring_pts[i], ring_pts[i + 1], Color(0.95, 0.75, 0.10, 0.8), 2.0)


func _draw_control_panel(cx: float, cy: float) -> void:
	# Gear/cog shape
	var outer_r := 16.0
	var inner_r := 10.0
	var teeth := 8
	var gear_pts: PackedVector2Array = []
	var gear_colors: PackedColorArray = []
	var gear_color := Color(0.50, 0.55, 0.65)

	for i in range(teeth):
		var base_angle: float = float(i) / teeth * TAU
		var tooth_half: float = TAU / teeth * 0.25

		# Outer tooth corners
		gear_pts.append(Vector2(cx + cos(base_angle - tooth_half) * outer_r, cy + sin(base_angle - tooth_half) * outer_r))
		gear_colors.append(gear_color)
		gear_pts.append(Vector2(cx + cos(base_angle + tooth_half) * outer_r, cy + sin(base_angle + tooth_half) * outer_r))
		gear_colors.append(gear_color)

		# Inner valley
		var next_angle: float = float(i + 1) / teeth * TAU
		var valley_angle: float = (base_angle + next_angle) / 2.0
		gear_pts.append(Vector2(cx + cos(valley_angle - tooth_half) * inner_r, cy + sin(valley_angle - tooth_half) * inner_r))
		gear_colors.append(gear_color.darkened(0.15))
		gear_pts.append(Vector2(cx + cos(valley_angle + tooth_half) * inner_r, cy + sin(valley_angle + tooth_half) * inner_r))
		gear_colors.append(gear_color.darkened(0.15))

	draw_polygon(gear_pts, gear_colors)

	# Gear border
	var border_pts: PackedVector2Array = gear_pts.duplicate()
	border_pts.append(gear_pts[0])
	draw_polyline(border_pts, Color(0.3, 0.35, 0.42), 1.0)

	# Center hole
	draw_circle(Vector2(cx, cy), 5, Color(0.35, 0.40, 0.48))
	draw_circle(Vector2(cx, cy), 3, Color(0.50, 0.55, 0.65))

	# Small colored squares inside (Windows colors — like Control Panel icon)
	draw_rect(Rect2(cx - 8, cy - 8, 5, 5), Color(0.20, 0.55, 0.85, 0.7))
	draw_rect(Rect2(cx + 3, cy - 8, 5, 5), Color(0.20, 0.70, 0.25, 0.7))
	draw_rect(Rect2(cx - 8, cy + 3, 5, 5), Color(0.85, 0.20, 0.20, 0.7))
	draw_rect(Rect2(cx + 3, cy + 3, 5, 5), Color(0.90, 0.75, 0.15, 0.7))
