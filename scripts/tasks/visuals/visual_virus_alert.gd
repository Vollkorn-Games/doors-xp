extends "res://scripts/tasks/task_visual.gd"

## Virus Alert visual: antivirus scan and threat removal.
## Steps: Acknowledge Warning → Open Antivirus → Start Scan → Scanning (wait) →
##        Quarantine Threat → Delete Virus

# Fake file paths for scanning animation
const SCAN_PATHS := [
	"C:\\Windows\\System32\\kernel32.dll",
	"C:\\Windows\\System32\\ntdll.dll",
	"C:\\Program Files\\Internet Explorer\\iexplore.exe",
	"C:\\Documents and Settings\\User\\Desktop\\game.exe",
	"C:\\Windows\\Temp\\suspicious.tmp",
	"C:\\Program Files\\Common Files\\update.exe",
	"C:\\Windows\\System32\\drivers\\bad_driver.sys",
]


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	draw_rect(Rect2(0, 0, w, h), Color(0.93, 0.92, 0.87))

	match _step_index:
		0: _draw_warning(w, h)
		1: _draw_antivirus(w, h)
		2: _draw_start_scan(w, h)
		3: _draw_scanning(w, h)
		4: _draw_quarantine(w, h)
		5: _draw_delete(w, h)
		_: _draw_warning(w, h)


func _draw_warning(w: float, h: float) -> void:
	# Red warning popup
	var cx := w / 2.0
	var popup_w := w * 0.75
	var popup_h := h * 0.6
	var popup := Rect2(cx - popup_w / 2, h * 0.18, popup_w, popup_h)

	# Red flashing border
	draw_rect(Rect2(popup.position.x - 3, popup.position.y - 3, popup.size.x + 6, popup.size.y + 6), Color(0.9, 0.15, 0.1))
	var inner_body := _draw_mini_window(popup, "Windows Security Alert", Color(0.85, 0.15, 0.1))

	# Warning triangle
	var tri_cx := inner_body.position.x + inner_body.size.x / 2.0
	var tri_cy := inner_body.position.y + 30
	var tri_pts := PackedVector2Array([
		Vector2(tri_cx, tri_cy - 18),
		Vector2(tri_cx - 20, tri_cy + 14),
		Vector2(tri_cx + 20, tri_cy + 14),
	])
	draw_polygon(tri_pts, PackedColorArray([Color(1.0, 0.85, 0.0), Color(1.0, 0.85, 0.0), Color(1.0, 0.85, 0.0)]))
	draw_polyline(PackedVector2Array([tri_pts[0], tri_pts[1], tri_pts[2], tri_pts[0]]), Color(0.6, 0.5, 0.0), 2.0)
	_draw_centered_text("!", Vector2(tri_cx, tri_cy + 4), 18, Color(0.0, 0.0, 0.0))

	# Warning text
	_draw_centered_text("THREAT DETECTED!", Vector2(tri_cx, tri_cy + 35), 14, Color(0.85, 0.1, 0.1))
	_draw_centered_text("A potentially dangerous file", Vector2(tri_cx, tri_cy + 55), 10, Color(0.3, 0.3, 0.3))
	_draw_centered_text("has been found on your system.", Vector2(tri_cx, tri_cy + 70), 10, Color(0.3, 0.3, 0.3))

	# Shield icon
	draw_circle(Vector2(inner_body.position.x + 20, inner_body.position.y + 30), 12, Color(0.85, 0.2, 0.15, 0.3))


func _draw_antivirus(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "XP Antivirus Pro 2003")

	# Shield icon
	var shield_x := body.position.x + 30
	var shield_y := body.position.y + 35
	_draw_shield(shield_x, shield_y, Color(0.85, 0.15, 0.15))

	# Status
	_draw_text("Protection Status:", Vector2(body.position.x + 55, body.position.y + 22), 11, Color(0.0, 0.0, 0.0))
	_draw_text("AT RISK", Vector2(body.position.x + 55, body.position.y + 38), 13, Color(0.85, 0.15, 0.15))

	# Info area
	var info_rect := Rect2(body.position.x + 8, body.position.y + 58, body.size.x - 16, 60)
	_draw_sunken_panel(info_rect)
	_draw_text("Last scan: Never", Vector2(info_rect.position.x + 6, info_rect.position.y + 16), 9, Color(0.4, 0.4, 0.4))
	_draw_text("Virus definitions: Jan 15, 2003", Vector2(info_rect.position.x + 6, info_rect.position.y + 32), 9, Color(0.4, 0.4, 0.4))
	_draw_text("Threats found: 1 unresolved", Vector2(info_rect.position.x + 6, info_rect.position.y + 48), 9, Color(0.85, 0.15, 0.15))

	# Scan button
	_draw_xp_button(Rect2(body.position.x + body.size.x / 2 - 50, body.position.y + body.size.y - 32, 100, 24), "Scan Now")


func _draw_start_scan(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "XP Antivirus Pro 2003")

	# Shield (green - scanning)
	_draw_shield(body.position.x + 30, body.position.y + 35, Color(0.2, 0.7, 0.2))

	_draw_text("Protection Status:", Vector2(body.position.x + 55, body.position.y + 22), 11, Color(0.0, 0.0, 0.0))
	_draw_text("Scanning...", Vector2(body.position.x + 55, body.position.y + 38), 13, Color(0.2, 0.6, 0.2))

	# Scan area
	var scan_rect := Rect2(body.position.x + 8, body.position.y + 58, body.size.x - 16, 50)
	_draw_sunken_panel(scan_rect)
	_draw_text("Threats found: 0", Vector2(scan_rect.position.x + 6, scan_rect.position.y + 16), 9, Color(0.0, 0.0, 0.0))
	_draw_text("Files scanned: 0", Vector2(scan_rect.position.x + 6, scan_rect.position.y + 32), 9, Color(0.4, 0.4, 0.4))

	# Highlighted scan button
	_draw_xp_button(Rect2(body.position.x + body.size.x / 2 - 50, body.position.y + body.size.y - 32, 100, 24), "Scan Now", true)


func _draw_scanning(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "XP Antivirus Pro 2003 - Scanning")

	# Animated file path
	var path_idx := int(_wait_progress * (SCAN_PATHS.size() - 1))
	path_idx = clampi(path_idx, 0, SCAN_PATHS.size() - 1)

	# Scan status
	var files_scanned := int(_wait_progress * 3847)
	var threats := 1 if _wait_progress > 0.6 else 0

	# File being scanned
	var file_rect := Rect2(body.position.x + 8, body.position.y + 8, body.size.x - 16, 18)
	_draw_sunken_panel(file_rect)
	_draw_text(SCAN_PATHS[path_idx], Vector2(file_rect.position.x + 4, file_rect.position.y + 13), 8, Color(0.0, 0.0, 0.0))

	# Progress bar
	_draw_progress_bar(Rect2(body.position.x + 8, body.position.y + 32, body.size.x - 16, 14), _wait_progress)

	# Stats
	_draw_text("Files scanned: %d" % files_scanned, Vector2(body.position.x + 8, body.position.y + 58), 10, Color(0.0, 0.0, 0.0))
	if threats > 0:
		_draw_text("Threats found: %d" % threats, Vector2(body.position.x + 8, body.position.y + 74), 10, Color(0.85, 0.15, 0.15))
		# Threat detail
		_draw_text("TROJAN.WIN32.BADBOY", Vector2(body.position.x + 20, body.position.y + 90), 9, Color(0.85, 0.15, 0.15))
	else:
		_draw_text("Threats found: 0", Vector2(body.position.x + 8, body.position.y + 74), 10, Color(0.2, 0.6, 0.2))

	# Percentage
	var pct := int(_wait_progress * 100.0)
	_draw_text("%d%% complete" % pct, Vector2(body.position.x + body.size.x - 90, body.position.y + 58), 10, Color(0.4, 0.4, 0.4))


func _draw_quarantine(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "Scan Results - 1 Threat Found")

	# Results list
	var list_rect := Rect2(body.position.x + 8, body.position.y + 8, body.size.x - 16, 60)
	_draw_sunken_panel(list_rect)

	# Column headers
	draw_rect(Rect2(list_rect.position.x + 1, list_rect.position.y + 1, list_rect.size.x - 2, 14), Color(0.88, 0.87, 0.84))
	_draw_text("Threat Name", Vector2(list_rect.position.x + 4, list_rect.position.y + 12), 8, Color(0.3, 0.3, 0.3))
	_draw_text("Risk", Vector2(list_rect.position.x + 160, list_rect.position.y + 12), 8, Color(0.3, 0.3, 0.3))
	_draw_text("Status", Vector2(list_rect.position.x + 210, list_rect.position.y + 12), 8, Color(0.3, 0.3, 0.3))

	# Threat row (highlighted red)
	var ry := list_rect.position.y + 16
	draw_rect(Rect2(list_rect.position.x + 1, ry, list_rect.size.x - 2, 18), Color(1.0, 0.9, 0.9))
	draw_rect(Rect2(list_rect.position.x + 1, ry, list_rect.size.x - 2, 18), Color(0.85, 0.15, 0.15, 0.3), false, 1.0)
	# Virus icon (red X)
	draw_circle(Vector2(list_rect.position.x + 12, ry + 9), 6, Color(0.85, 0.15, 0.15))
	_draw_centered_text("X", Vector2(list_rect.position.x + 12, ry + 9), 8, Color(1.0, 1.0, 1.0))
	_draw_text("TROJAN.WIN32.BADBOY", Vector2(list_rect.position.x + 22, ry + 14), 9, Color(0.6, 0.0, 0.0))
	_draw_text("High", Vector2(list_rect.position.x + 160, ry + 14), 9, Color(0.85, 0.15, 0.15))
	_draw_text("Active", Vector2(list_rect.position.x + 210, ry + 14), 9, Color(0.85, 0.15, 0.15))

	# Action buttons
	_draw_xp_button(Rect2(body.position.x + 10, body.position.y + 80, 90, 22), "Quarantine", true)
	_draw_xp_button(Rect2(body.position.x + 110, body.position.y + 80, 70, 22), "Ignore")
	_draw_xp_button(Rect2(body.position.x + 190, body.position.y + 80, 70, 22), "Details")


func _draw_delete(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "Quarantine Manager")

	# Quarantine list
	var list_rect := Rect2(body.position.x + 8, body.position.y + 8, body.size.x - 16, 50)
	_draw_sunken_panel(list_rect)

	# Headers
	draw_rect(Rect2(list_rect.position.x + 1, list_rect.position.y + 1, list_rect.size.x - 2, 14), Color(0.88, 0.87, 0.84))
	_draw_text("Threat", Vector2(list_rect.position.x + 4, list_rect.position.y + 12), 8, Color(0.3, 0.3, 0.3))
	_draw_text("Date", Vector2(list_rect.position.x + 180, list_rect.position.y + 12), 8, Color(0.3, 0.3, 0.3))

	# Selected item
	var ry := list_rect.position.y + 16
	draw_rect(Rect2(list_rect.position.x + 1, ry, list_rect.size.x - 2, 18), Color(0.2, 0.4, 0.8))
	_draw_text("TROJAN.WIN32.BADBOY", Vector2(list_rect.position.x + 4, ry + 14), 9, Color(1.0, 1.0, 1.0))
	_draw_text("Today", Vector2(list_rect.position.x + 180, ry + 14), 9, Color(1.0, 1.0, 1.0))

	# Delete button highlighted
	_draw_xp_button(Rect2(body.position.x + 10, body.position.y + 70, 80, 22), "Delete", true)
	_draw_xp_button(Rect2(body.position.x + 100, body.position.y + 70, 80, 22), "Restore")

	# Virus icon with X through it
	var vx := body.position.x + body.size.x / 2
	var vy := body.position.y + body.size.y - 40
	draw_circle(Vector2(vx, vy), 14, Color(0.85, 0.15, 0.15, 0.3))
	# Bug icon
	draw_circle(Vector2(vx, vy - 3), 5, Color(0.4, 0.4, 0.4))
	draw_circle(Vector2(vx, vy + 4), 7, Color(0.4, 0.4, 0.4))
	# Red X over it
	draw_line(Vector2(vx - 12, vy - 12), Vector2(vx + 12, vy + 12), Color(0.9, 0.1, 0.1), 3.0)
	draw_line(Vector2(vx + 12, vy - 12), Vector2(vx - 12, vy + 12), Color(0.9, 0.1, 0.1), 3.0)


func _draw_shield(x: float, y: float, color: Color) -> void:
	var pts := PackedVector2Array([
		Vector2(x, y - 15),
		Vector2(x - 12, y - 8),
		Vector2(x - 12, y + 4),
		Vector2(x - 8, y + 10),
		Vector2(x, y + 15),
		Vector2(x + 8, y + 10),
		Vector2(x + 12, y + 4),
		Vector2(x + 12, y - 8),
	])
	var colors: PackedColorArray = []
	for i in range(pts.size()):
		colors.append(color)
	draw_polygon(pts, colors)
	# Shield highlight
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[4], pts[5], pts[6], pts[7], pts[0]]), color.darkened(0.3), 1.5)
	# Checkmark or X in shield
	if color.g > 0.5:  # Green = checkmark
		draw_line(Vector2(x - 5, y), Vector2(x - 1, y + 5), Color(1.0, 1.0, 1.0), 2.0)
		draw_line(Vector2(x - 1, y + 5), Vector2(x + 6, y - 5), Color(1.0, 1.0, 1.0), 2.0)
	else:  # Red = X
		draw_line(Vector2(x - 5, y - 5), Vector2(x + 5, y + 5), Color(1.0, 1.0, 1.0), 2.0)
		draw_line(Vector2(x + 5, y - 5), Vector2(x - 5, y + 5), Color(1.0, 1.0, 1.0), 2.0)
