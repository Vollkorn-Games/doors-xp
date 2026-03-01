extends Control

## Draws a Windows XP "Bliss" wallpaper — faithful to the original.
## Single dominant hill rising from lower-left, distant hills, natural clouds.

const GRASS_SHADER := preload("res://shaders/grass_overlay.gdshader")

# Sky — deep blue at top, lighter toward horizon
const SKY_TOP := Color(0.18, 0.42, 0.78)
const SKY_MID := Color(0.38, 0.60, 0.90)
const SKY_HORIZON := Color(0.68, 0.82, 0.95)

# Hill greens — rich, warm, saturated
const GRASS_SUNLIT := Color(0.35, 0.72, 0.18)
const GRASS_MID := Color(0.28, 0.60, 0.14)
const GRASS_SHADOW := Color(0.18, 0.45, 0.08)
const GRASS_DARK := Color(0.14, 0.35, 0.06)

# Distant hills
const DISTANT_HILL_COLOR := Color(0.30, 0.48, 0.35, 0.20)

# Cloud definitions: [x%, y%, scale, type]
# type 0 = cumulus (fluffy), type 1 = small puffy, type 2 = wispy
const CLOUDS := [
	# Large cumulus clouds
	[0.52, 0.12, 1.4, 0],
	[0.80, 0.10, 1.1, 0],
	# Medium puffy clouds
	[0.22, 0.08, 0.8, 1],
	[0.68, 0.22, 0.7, 1],
	# Small accent clouds
	[0.38, 0.18, 0.5, 1],
	[0.92, 0.20, 0.45, 1],
	# Wispy high clouds
	[0.15, 0.06, 0.6, 2],
	[0.60, 0.05, 0.7, 2],
]

# Cumulus cloud shape (fluffy, rounded)
const CUMULUS_BUBBLES := [
	[0.0, -5.0, 30.0],
	[-20.0, 2.0, 26.0],
	[20.0, 2.0, 26.0],
	[-10.0, -14.0, 22.0],
	[10.0, -14.0, 22.0],
	[0.0, -20.0, 18.0],
	[0.0, 10.0, 24.0],
	[-32.0, 8.0, 20.0],
	[32.0, 8.0, 20.0],
	[-40.0, 12.0, 14.0],
	[40.0, 12.0, 14.0],
	[-16.0, 14.0, 18.0],
	[16.0, 14.0, 18.0],
]

# Small puffy cloud shape
const PUFFY_BUBBLES := [
	[0.0, 0.0, 22.0],
	[-16.0, 3.0, 18.0],
	[16.0, 3.0, 18.0],
	[-6.0, -10.0, 16.0],
	[6.0, -10.0, 16.0],
	[0.0, 8.0, 16.0],
	[-24.0, 6.0, 12.0],
	[24.0, 6.0, 12.0],
]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_grass_overlay()


func _setup_grass_overlay() -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color.WHITE
	var mat := ShaderMaterial.new()
	mat.shader = GRASS_SHADER
	mat.set_shader_parameter("resolution", Vector2(1024.0, 768.0))
	overlay.material = mat
	add_child(overlay)


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	_draw_sky(w, h)
	_draw_distant_hills(w, h)
	_draw_main_hill(w, h)
	_draw_clouds(w, h)


# --- Sky ---

func _draw_sky(w: float, h: float) -> void:
	var bands := 64
	for i in range(bands):
		var t := float(i) / bands
		var next_t := float(i + 1) / bands
		# Three-stop gradient: top -> mid -> horizon
		var color: Color
		if t < 0.5:
			color = SKY_TOP.lerp(SKY_MID, t * 2.0)
		else:
			color = SKY_MID.lerp(SKY_HORIZON, (t - 0.5) * 2.0)
		var y := t * h
		var band_h := (next_t - t) * h + 1.0
		draw_rect(Rect2(0, y, w, band_h), color)


# --- Distant hills on the horizon ---

func _draw_distant_hills(w: float, h: float) -> void:
	# Faint background hills at the horizon line
	var segments := 60
	var points: PackedVector2Array = []
	var colors: PackedColorArray = []
	var hill_color := DISTANT_HILL_COLOR

	for i in range(segments + 1):
		var t := float(i) / segments
		var x := t * w
		# Gentle, wide undulations for distant terrain
		var y := h * 0.52
		y += sin(t * PI * 1.2 + 0.8) * h * 0.03
		y += sin(t * PI * 3.0 + 2.0) * h * 0.012
		points.append(Vector2(x, y))
		colors.append(hill_color)

	# Close polygon to bottom of the main hill area
	points.append(Vector2(w, h * 0.70))
	colors.append(Color(hill_color, 0.0))
	points.append(Vector2(0, h * 0.70))
	colors.append(Color(hill_color, 0.0))

	draw_polygon(points, colors)


# --- Main foreground hill ---

static func _hill_curve(t: float) -> float:
	## Returns the hill Y offset (0..1 range) for a given horizontal position t (0..1).
	## Single dominant hill: rises from lower-left, peaks right-of-center, descends.
	# Primary hill: broad peak at ~60% from left
	var curve := 0.0
	curve += sin((t - 0.1) * PI * 0.65) * 0.18  # Main rise/peak
	curve += sin(t * PI * 1.8 + 0.5) * 0.03      # Gentle secondary undulation
	curve += sin(t * PI * 5.0 + 1.5) * 0.005      # Subtle terrain micro-detail
	return curve


func _draw_main_hill(w: float, h: float) -> void:
	var segments := 100
	var points: PackedVector2Array = []
	var colors: PackedColorArray = []

	# The hill baseline — bottom edge of where the hill can appear
	var base_y := h * 0.68

	for i in range(segments + 1):
		var t := float(i) / segments
		var x := t * w

		var curve := _hill_curve(t)
		var y := base_y - curve * h

		points.append(Vector2(x, y))

		# Slope-based lighting: compute slope for this segment
		var slope := 0.0
		if i > 0 and i < segments:
			var t_prev := float(i - 1) / segments
			var t_next := float(i + 1) / segments
			var y_prev := base_y - _hill_curve(t_prev) * h
			var y_next := base_y - _hill_curve(t_next) * h
			slope = (y_prev - y_next) / (2.0 * w / segments)  # Positive = going uphill

		# Map slope to color: uphill (facing light) = sunlit, downhill = shadow
		var light_factor := clampf(slope * 8.0 + 0.5, 0.0, 1.0)
		var col := GRASS_SHADOW.lerp(GRASS_SUNLIT, light_factor)

		# Add depth: lower on screen = slightly darker
		var depth := clampf((y - h * 0.35) / (h * 0.5), 0.0, 1.0)
		col = col.lerp(GRASS_DARK, depth * 0.25)

		colors.append(col)

	# Close polygon at the screen bottom
	points.append(Vector2(w, h + 2))
	colors.append(GRASS_DARK)
	points.append(Vector2(0, h + 2))
	colors.append(GRASS_DARK)

	draw_polygon(points, colors)


# --- Clouds ---

func _draw_clouds(w: float, h: float) -> void:
	for cloud_data: Array in CLOUDS:
		var cx: float = cloud_data[0] * w
		var cy: float = cloud_data[1] * h
		var s: float = cloud_data[2]
		var cloud_type: int = int(cloud_data[3])

		match cloud_type:
			0: _draw_cumulus(Vector2(cx, cy), s)
			1: _draw_puffy(Vector2(cx, cy), s)
			2: _draw_wispy(Vector2(cx, cy), s)


func _draw_cumulus(center: Vector2, s: float) -> void:
	# Shadow
	var shadow := Color(0.55, 0.62, 0.78, 0.10)
	for b: Array in CUMULUS_BUBBLES:
		draw_circle(center + Vector2(b[0], b[1]) * s + Vector2(3, 5) * s, b[2] * s, shadow)
	# Underside (slightly grey)
	var underside := Color(0.88, 0.90, 0.94, 0.7)
	for b: Array in CUMULUS_BUBBLES:
		if b[1] > 4.0:  # Only bottom bubbles
			draw_circle(center + Vector2(b[0], b[1]) * s + Vector2(0, 2) * s, b[2] * s * 0.95, underside)
	# Body
	var body := Color(1.0, 1.0, 1.0, 0.88)
	for b: Array in CUMULUS_BUBBLES:
		draw_circle(center + Vector2(b[0], b[1]) * s, b[2] * s, body)
	# Highlight on top
	var highlight := Color(1.0, 1.0, 1.0, 0.4)
	for b: Array in CUMULUS_BUBBLES:
		if b[1] < -5.0:  # Only top bubbles
			draw_circle(center + Vector2(b[0], b[1] - 2.0) * s, b[2] * s * 0.7, highlight)


func _draw_puffy(center: Vector2, s: float) -> void:
	# Shadow
	var shadow := Color(0.55, 0.62, 0.78, 0.08)
	for b: Array in PUFFY_BUBBLES:
		draw_circle(center + Vector2(b[0], b[1]) * s + Vector2(2, 3) * s, b[2] * s, shadow)
	# Body
	var body := Color(1.0, 1.0, 1.0, 0.82)
	for b: Array in PUFFY_BUBBLES:
		draw_circle(center + Vector2(b[0], b[1]) * s, b[2] * s, body)


func _draw_wispy(center: Vector2, s: float) -> void:
	# Thin, stretched wispy cloud (high altitude)
	var wispy := Color(1.0, 1.0, 1.0, 0.35)
	# Horizontal ellipses
	var stretches := [
		[0.0, 0.0, 50.0, 8.0],
		[-30.0, 2.0, 35.0, 6.0],
		[35.0, -1.0, 40.0, 7.0],
		[60.0, 3.0, 25.0, 5.0],
	]
	for st: Array in stretches:
		var pos := center + Vector2(st[0], st[1]) * s
		var w_radius: float = st[2] * s
		var h_radius: float = st[3] * s
		# Approximate ellipse with a stretched circle
		# Draw several small circles along the length
		var steps := int(w_radius / 4.0)
		for j in range(steps):
			var jt: float = float(j) / maxf(float(steps - 1), 1.0)
			var px: float = pos.x - w_radius + jt * w_radius * 2.0
			var falloff: float = 1.0 - abs(jt - 0.5) * 2.0  # Fade at edges
			var r := h_radius * falloff * falloff
			if r > 1.0:
				draw_circle(Vector2(px, pos.y), r, wispy)
