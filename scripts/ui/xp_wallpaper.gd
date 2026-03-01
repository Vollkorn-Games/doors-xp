extends Control

## Draws a Windows XP "Bliss"-inspired wallpaper programmatically.
## Blue sky gradient, rolling green hill, and soft white clouds.

# Sky colors
const SKY_TOP := Color(0.30, 0.55, 0.88)
const SKY_HORIZON := Color(0.62, 0.78, 0.94)

# Hill / grass colors
const GRASS_BRIGHT := Color(0.32, 0.68, 0.18)
const GRASS_DARK := Color(0.22, 0.52, 0.10)
const GRASS_SHADOW := Color(0.18, 0.42, 0.08)

# Cloud color
const CLOUD_COLOR := Color(1.0, 1.0, 1.0, 0.8)

# Pre-defined cloud layouts (center_x%, center_y%, scale)
const CLOUD_POSITIONS := [
	[0.22, 0.12, 0.9],
	[0.52, 0.10, 1.2],
	[0.80, 0.16, 1.0],
	[0.38, 0.30, 0.65],
	[0.88, 0.34, 0.55],
]

# Cloud bubble offsets (relative positions and radii for one cloud shape)
const CLOUD_BUBBLES := [
	[0.0, 0.0, 26.0],
	[-24.0, 5.0, 22.0],
	[24.0, 5.0, 22.0],
	[-13.0, -10.0, 18.0],
	[13.0, -10.0, 18.0],
	[0.0, 10.0, 20.0],
	[-36.0, 8.0, 15.0],
	[36.0, 8.0, 15.0],
	[-8.0, -16.0, 14.0],
	[8.0, -16.0, 14.0],
]


const GRASS_SHADER := preload("res://shaders/grass_overlay.gdshader")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_grass_overlay()


func _setup_grass_overlay() -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color.WHITE  # Shader overrides this
	var mat := ShaderMaterial.new()
	mat.shader = GRASS_SHADER
	mat.set_shader_parameter("resolution", Vector2(1024.0, 768.0))
	mat.set_shader_parameter("hill_base", 0.58)
	overlay.material = mat
	add_child(overlay)


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	_draw_sky(w, h)
	_draw_hill(w, h)
	_draw_clouds(w, h)


func _draw_sky(w: float, h: float) -> void:
	# Vertical gradient from deep blue at top to lighter blue at horizon
	var bands := 48
	for i in range(bands):
		var t := float(i) / bands
		var next_t := float(i + 1) / bands
		var color := SKY_TOP.lerp(SKY_HORIZON, t * t)  # Quadratic easing for natural look
		var y := t * h
		var band_h := (next_t - t) * h + 1.0
		draw_rect(Rect2(0, y, w, band_h), color)


func _draw_hill(w: float, h: float) -> void:
	# Rolling hill across the bottom ~40% of the screen
	# Inspired by the classic Bliss wallpaper gentle curve
	var segments := 80
	var points: PackedVector2Array = []
	var colors: PackedColorArray = []

	# Hill height baseline — the hill occupies roughly y=55% to y=100%
	var base_y := h * 0.58

	for i in range(segments + 1):
		var t := float(i) / segments
		var x := t * w

		# Main gentle rolling curve
		var curve := 0.0
		curve += sin(t * PI * 0.85 + 0.4) * h * 0.10   # Primary broad hill
		curve += sin(t * PI * 2.2 + 1.0) * h * 0.025    # Secondary undulation
		curve += sin(t * PI * 4.5 + 2.5) * h * 0.008    # Subtle terrain texture

		var y := base_y + curve

		points.append(Vector2(x, y))
		# Color varies slightly along the hill: brighter on top, darker lower
		var hill_t := clampf((y - base_y + h * 0.12) / (h * 0.35), 0.0, 1.0)
		colors.append(GRASS_BRIGHT.lerp(GRASS_DARK, hill_t * 0.6))

	# Close polygon at bottom-right and bottom-left corners
	points.append(Vector2(w, h + 2))
	colors.append(GRASS_SHADOW)
	points.append(Vector2(0, h + 2))
	colors.append(GRASS_SHADOW)

	draw_polygon(points, colors)

	# Draw a subtle lighter highlight strip near the hill crest
	_draw_hill_highlight(w, h, base_y, segments)


func _draw_hill_highlight(w: float, h: float, base_y: float, segments: int) -> void:
	# Thin lighter strip along the very top of the hill for depth
	var highlight_points: PackedVector2Array = []
	var highlight_colors: PackedColorArray = []
	var highlight_color := Color(0.45, 0.78, 0.28, 0.35)

	for i in range(segments + 1):
		var t := float(i) / segments
		var x := t * w
		var curve := 0.0
		curve += sin(t * PI * 0.85 + 0.4) * h * 0.10
		curve += sin(t * PI * 2.2 + 1.0) * h * 0.025
		curve += sin(t * PI * 4.5 + 2.5) * h * 0.008
		var y := base_y + curve
		highlight_points.append(Vector2(x, y))
		highlight_colors.append(highlight_color)

	# Offset strip below the crest
	for i in range(segments, -1, -1):
		var t := float(i) / segments
		var x := t * w
		var curve := 0.0
		curve += sin(t * PI * 0.85 + 0.4) * h * 0.10
		curve += sin(t * PI * 2.2 + 1.0) * h * 0.025
		curve += sin(t * PI * 4.5 + 2.5) * h * 0.008
		var y := base_y + curve + h * 0.03
		highlight_points.append(Vector2(x, y))
		highlight_colors.append(Color(highlight_color, 0.0))

	draw_polygon(highlight_points, highlight_colors)


func _draw_clouds(w: float, h: float) -> void:
	for cloud_data: Array in CLOUD_POSITIONS:
		var cx: float = cloud_data[0] * w
		var cy: float = cloud_data[1] * h
		var s: float = cloud_data[2]
		_draw_single_cloud(Vector2(cx, cy), s)


func _draw_single_cloud(center: Vector2, s: float) -> void:
	# Draw cloud shadow first (offset down-right)
	var shadow_color := Color(0.5, 0.6, 0.75, 0.12)
	for bubble: Array in CLOUD_BUBBLES:
		var offset := Vector2(bubble[0], bubble[1]) * s
		var radius: float = bubble[2] * s
		draw_circle(center + offset + Vector2(3, 4) * s, radius, shadow_color)

	# Draw cloud body
	for bubble: Array in CLOUD_BUBBLES:
		var offset := Vector2(bubble[0], bubble[1]) * s
		var radius: float = bubble[2] * s
		draw_circle(center + offset, radius, CLOUD_COLOR)
