shader_type canvas_item;

// Smooth manicured-lawn grass texture overlay.
// Adds subtle noise-based color variation and soft lighting to the hill surface.
// No grass blade silhouettes — faithful to the original Bliss look.

uniform vec2 resolution = vec2(1024.0, 768.0);

// Hill shape parameters (must match xp_wallpaper.gd _hill_curve)
float get_hill_y(float x) {
	float curve = 0.0;
	curve += sin((x - 0.1) * 3.14159 * 0.65) * 0.18;
	curve += sin(x * 3.14159 * 1.8 + 0.5) * 0.03;
	curve += sin(x * 3.14159 * 5.0 + 1.5) * 0.005;
	return 0.68 - curve;
}

// Hash / noise
float hash2(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

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

float fbm(vec2 p) {
	float v = 0.0;
	v += noise(p) * 0.5;
	v += noise(p * 2.0 + vec2(5.3, 1.7)) * 0.25;
	v += noise(p * 4.0 + vec2(9.1, 3.4)) * 0.125;
	return v;
}

void fragment() {
	vec2 uv = UV;

	float hill_y = get_hill_y(uv.x);

	// Smooth fade-in at the hill edge (transparent above hill)
	float edge_fade = smoothstep(hill_y - 0.005, hill_y + 0.015, uv.y);

	// === Grass texture: layered noise for natural lawn look ===
	vec2 grass_uv = uv * resolution;

	// Fine grass grain (directional, slightly vertical)
	float fine_grain = noise(vec2(grass_uv.x * 0.12, grass_uv.y * 0.03));

	// Medium-scale color patches (clumps of slightly different grass color)
	float patches = fbm(grass_uv * 0.015 + vec2(42.0, 17.0));

	// Large-scale variation (broad light/shadow areas)
	float broad = fbm(grass_uv * 0.005 + vec2(100.0, 200.0));

	float pattern = fine_grain * 0.3 + patches * 0.45 + broad * 0.25;

	// Color modulation
	vec3 grass_light = vec3(0.38, 0.74, 0.22);
	vec3 grass_dark = vec3(0.20, 0.50, 0.10);
	vec3 grass_color = mix(grass_dark, grass_light, pattern);

	// Depth darkening: lower on screen = slightly darker
	float depth_factor = smoothstep(0.45, 0.95, uv.y);
	grass_color *= mix(1.05, 0.85, depth_factor);

	// Very subtle surface alpha — this blends with the polygon colors beneath
	float alpha = 0.22 * edge_fade;

	COLOR = vec4(grass_color, alpha);
}
