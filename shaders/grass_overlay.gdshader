shader_type canvas_item;

// Grass blade silhouettes along the hill crest + subtle surface texture.
// Matches the hill curve from xp_wallpaper.gd.

uniform vec2 resolution = vec2(1024.0, 768.0);
uniform float hill_base = 0.58;
uniform float wind_speed : hint_range(0.0, 3.0) = 0.8;
uniform float wind_strength : hint_range(0.0, 0.01) = 0.004;

// Hash functions
float hash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

float hash2(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Simple value noise
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash2(i);
	float b = hash2(i + vec2(1.0, 0.0));
	float c = hash2(i + vec2(0.0, 1.0));
	float d = hash2(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Hill curve Y in UV space (must match xp_wallpaper.gd sine waves)
float get_hill_y(float x) {
	float curve = 0.0;
	curve += sin(x * 3.14159 * 0.85 + 0.4) * 0.10;
	curve += sin(x * 3.14159 * 2.2 + 1.0) * 0.025;
	curve += sin(x * 3.14159 * 4.5 + 2.5) * 0.008;
	return hill_base + curve;
}

void fragment() {
	vec2 uv = UV;
	vec2 px = 1.0 / resolution; // Size of one pixel in UV space

	float hill_y = get_hill_y(uv.x);

	// === GRASS BLADE SILHOUETTES along the hill crest ===
	float blade_alpha = 0.0;
	vec3 blade_color = vec3(0.0);

	// Blade spacing: one blade every ~5 pixels
	float blade_spacing = 5.0;
	float pixel_x = uv.x * resolution.x;
	float col_idx = floor(pixel_x / blade_spacing);

	// Check this column and neighbors for blade overlap
	for (float di = -1.0; di <= 1.0; di += 1.0) {
		float ci = col_idx + di;
		float r1 = hash(ci * 1.7);
		float r2 = hash(ci * 3.1 + 50.0);
		float r3 = hash(ci * 5.3 + 100.0);

		// Blade center X in UV space (with random jitter)
		float bx = (ci * blade_spacing + blade_spacing * 0.5 + (r1 - 0.5) * blade_spacing * 0.5) * px.x;

		// Hill Y at this blade's X position
		float by_base = get_hill_y(bx);

		// Blade height: 10-24 pixels
		float b_height = (10.0 + r2 * 14.0) * px.y;
		float by_top = by_base - b_height;

		// Wind sway (stronger at tip)
		float wind = sin(TIME * wind_speed + ci * 0.37 + r3 * 6.28) * wind_strength;

		if (uv.y >= by_top && uv.y <= by_base) {
			// 0 at tip, 1 at base
			float progress = (uv.y - by_top) / max(by_base - by_top, 0.001);

			// Blade width: thin at tip (~0.5px), wider at base (~2.5px)
			float b_width = mix(0.6, 2.8, progress) * px.x;

			// Apply wind (more sway at tip)
			float wind_offset = wind * (1.0 - progress);
			float dx = abs(uv.x - bx - wind_offset);

			float a = smoothstep(b_width, b_width * 0.15, dx);
			if (a > blade_alpha) {
				blade_alpha = a;
				// Per-blade color variation
				float cm = hash(ci * 7.7 + 200.0);
				blade_color = mix(
					vec3(0.24, 0.56, 0.13),
					vec3(0.40, 0.74, 0.24),
					cm
				);
				// Lighter at tip, darker at base
				blade_color *= mix(1.15, 0.75, progress);
			}
		}
	}

	// === SURFACE GRASS TEXTURE on the hill ===
	float surface_alpha = 0.0;
	vec3 surface_color = vec3(0.0);

	if (uv.y > hill_y) {
		// Layered noise for fibrous grass look
		float n1 = noise(vec2(uv.x * resolution.x * 0.15, uv.y * resolution.y * 0.04));
		float n2 = noise(uv * resolution * 0.08 + vec2(73.0, 41.0));

		// Vertical streak pattern (grass fiber direction)
		float streak = noise(vec2(uv.x * resolution.x * 0.25, uv.y * resolution.y * 0.015));

		float pattern = n1 * 0.4 + streak * 0.4 + n2 * 0.2;

		surface_color = mix(
			vec3(0.20, 0.48, 0.09),
			vec3(0.36, 0.70, 0.20),
			pattern
		);

		// Fade in from the hill edge
		float edge_dist = (uv.y - hill_y) / 0.03;
		surface_alpha = 0.25 * smoothstep(0.0, 1.0, edge_dist);
	}

	// === Combine layers ===
	float final_alpha = max(surface_alpha, blade_alpha * 0.9);
	vec3 final_color = blade_color;

	if (blade_alpha < 0.01) {
		final_color = surface_color;
	} else if (surface_alpha > 0.01) {
		final_color = mix(surface_color, blade_color, blade_alpha);
	}

	COLOR = vec4(final_color, final_alpha);
}
