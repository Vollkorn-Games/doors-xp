extends "res://scripts/tasks/task_visual.gd"

## Install Software visual: XP install wizard flow.
## Steps: Insert CD → Run Setup → Accept License → Choose Dir → Next →
##        Installing (wait) → Finish


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	draw_rect(Rect2(0, 0, w, h), Color(0.93, 0.92, 0.87))

	match _step_index:
		0: _draw_insert_cd(w, h)
		1: _draw_run_setup(w, h)
		2: _draw_accept_license(w, h)
		3: _draw_choose_dir(w, h)
		4: _draw_next(w, h)
		5: _draw_installing(w, h)
		6: _draw_finish(w, h)
		_: _draw_insert_cd(w, h)


func _draw_insert_cd(w: float, h: float) -> void:
	var cx := w / 2.0

	# CD-ROM drive
	var drive_rect := Rect2(cx - 60, h * 0.2, 120, 30)
	draw_rect(drive_rect, Color(0.82, 0.82, 0.80))
	draw_rect(drive_rect, Color(0.5, 0.5, 0.48), false, 1.5)
	# Drive tray slot
	draw_rect(Rect2(cx - 40, h * 0.2 + 8, 80, 3), Color(0.4, 0.4, 0.38))
	# LED
	draw_circle(Vector2(cx + 45, h * 0.2 + 15), 3, Color(0.3, 0.8, 0.3))
	# Eject button
	draw_rect(Rect2(cx + 38, h * 0.2 + 22, 10, 5), Color(0.7, 0.7, 0.68))

	# CD disc
	var cd_y := h * 0.2 + 45
	draw_circle(Vector2(cx, cd_y), 30, Color(0.75, 0.80, 0.90))
	draw_circle(Vector2(cx, cd_y), 30, Color(0.5, 0.55, 0.65), false, 1.0)
	draw_circle(Vector2(cx, cd_y), 8, Color(0.85, 0.85, 0.85))
	draw_circle(Vector2(cx, cd_y), 8, Color(0.5, 0.5, 0.5), false, 1.0)
	# Rainbow refraction on disc
	draw_circle(Vector2(cx - 5, cd_y - 5), 18, Color(0.8, 0.4, 0.9, 0.1))
	draw_circle(Vector2(cx + 8, cd_y + 3), 15, Color(0.4, 0.9, 0.4, 0.1))
	# Label
	_draw_centered_text("CoolApp 2.0", Vector2(cx, cd_y + 3), 9, Color(0.2, 0.2, 0.5))

	# Arrow pointing down
	var arrow_pts := PackedVector2Array([
		Vector2(cx - 8, cd_y + 35),
		Vector2(cx + 8, cd_y + 35),
		Vector2(cx, cd_y + 48),
	])
	draw_polygon(arrow_pts, PackedColorArray([Color(0.3, 0.3, 0.3), Color(0.3, 0.3, 0.3), Color(0.3, 0.3, 0.3)]))

	_draw_centered_text("Insert the installation disc", Vector2(cx, h * 0.85), 11, Color(0.3, 0.3, 0.3))


func _draw_run_setup(w: float, h: float) -> void:
	# Autoplay dialog
	var body := _draw_mini_window(Rect2(20, 10, w - 40, h - 20), "CoolApp 2.0 - AutoPlay")

	_draw_text("This disc contains software.", Vector2(body.position.x + 8, body.position.y + 22), 10, Color(0.0, 0.0, 0.0))
	_draw_text("What would you like to do?", Vector2(body.position.x + 8, body.position.y + 38), 10, Color(0.0, 0.0, 0.0))

	# Options (radio buttons)
	var options := [
		["Run setup.exe", true],
		["Open folder to view files", false],
		["Take no action", false],
	]
	for i in range(options.size()):
		var oy := body.position.y + 58 + float(i) * 22
		var is_selected: bool = options[i][1]
		# Radio button
		draw_circle(Vector2(body.position.x + 20, oy + 6), 6, Color(1.0, 1.0, 1.0))
		draw_circle(Vector2(body.position.x + 20, oy + 6), 6, Color(0.4, 0.4, 0.4), false, 1.0)
		if is_selected:
			draw_circle(Vector2(body.position.x + 20, oy + 6), 3, Color(0.0, 0.0, 0.0))
			draw_rect(Rect2(body.position.x + 12, oy - 2, body.size.x - 20, 18), Color(0.2, 0.4, 0.8, 0.1))
		_draw_text(options[i][0], Vector2(body.position.x + 32, oy + 11), 10, Color(0.0, 0.0, 0.0))

	# OK button
	_draw_xp_button(Rect2(body.end.x - 70, body.end.y - 28, 60, 22), "OK", true)


func _draw_accept_license(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(15, 5, w - 30, h - 10), "CoolApp 2.0 Setup")

	# Wizard sidebar (blue gradient)
	var sidebar_w := 60.0
	for i in range(20):
		var t := float(i) / 20
		var sy := body.position.y + t * body.size.y
		var sh := body.size.y / 20.0 + 1
		draw_rect(Rect2(body.position.x, sy, sidebar_w, sh), Color(0.08, 0.20, 0.55).lerp(Color(0.15, 0.40, 0.85), t))

	# EULA text area
	var text_x := body.position.x + sidebar_w + 6
	_draw_text("License Agreement", Vector2(text_x, body.position.y + 16), 11, Color(0.0, 0.0, 0.0))

	var eula_rect := Rect2(text_x, body.position.y + 22, body.size.x - sidebar_w - 12, 80)
	_draw_sunken_panel(eula_rect)

	# EULA text (tiny, wall of text)
	var eula_lines := [
		"END USER LICENSE AGREEMENT",
		"",
		"BY INSTALLING THIS SOFTWARE",
		"YOU AGREE TO THE FOLLOWING",
		"TERMS AND CONDITIONS...",
		"",
		"1. You may install this on one",
		"   (1) computer only.",
		"2. You may not redistribute...",
		"3. THE SOFTWARE IS PROVIDED",
		"   AS-IS WITHOUT WARRANTY...",
	]
	for i in range(eula_lines.size()):
		var ly := eula_rect.position.y + 10 + float(i) * 10
		if ly < eula_rect.end.y - 4:
			_draw_text(eula_lines[i], Vector2(eula_rect.position.x + 4, ly), 7, Color(0.0, 0.0, 0.0))

	# Accept radio
	var ry := eula_rect.end.y + 8
	draw_circle(Vector2(text_x + 8, ry + 6), 5, Color(1.0, 1.0, 1.0))
	draw_circle(Vector2(text_x + 8, ry + 6), 5, Color(0.4, 0.4, 0.4), false, 1.0)
	draw_circle(Vector2(text_x + 8, ry + 6), 2, Color(0.0, 0.0, 0.0))
	_draw_text("I accept the terms", Vector2(text_x + 18, ry + 11), 9, Color(0.0, 0.0, 0.0))

	# Buttons
	_draw_xp_button(Rect2(body.end.x - 130, body.end.y - 26, 60, 20), "Next >", true)
	_draw_xp_button(Rect2(body.end.x - 65, body.end.y - 26, 60, 20), "Cancel")


func _draw_choose_dir(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(15, 5, w - 30, h - 10), "CoolApp 2.0 Setup")

	# Sidebar
	var sidebar_w := 60.0
	for i in range(20):
		var t := float(i) / 20
		var sy := body.position.y + t * body.size.y
		var sh := body.size.y / 20.0 + 1
		draw_rect(Rect2(body.position.x, sy, sidebar_w, sh), Color(0.08, 0.20, 0.55).lerp(Color(0.15, 0.40, 0.85), t))

	var text_x := body.position.x + sidebar_w + 6
	_draw_text("Choose Install Location", Vector2(text_x, body.position.y + 16), 11, Color(0.0, 0.0, 0.0))
	_draw_text("Select the folder to install to:", Vector2(text_x, body.position.y + 34), 9, Color(0.3, 0.3, 0.3))

	# Path field
	var path_rect := Rect2(text_x, body.position.y + 42, body.size.x - sidebar_w - 60, 18)
	_draw_sunken_panel(path_rect)
	_draw_text("C:\\Program Files\\CoolApp", Vector2(path_rect.position.x + 4, path_rect.position.y + 13), 9, Color(0.0, 0.0, 0.0))
	_draw_xp_button(Rect2(path_rect.end.x + 4, path_rect.position.y, 40, 18), "Browse")

	# Space info
	_draw_text("Space required: 127 MB", Vector2(text_x, body.position.y + 72), 9, Color(0.3, 0.3, 0.3))
	_draw_text("Space available: 11.2 GB", Vector2(text_x, body.position.y + 86), 9, Color(0.3, 0.3, 0.3))

	# Folder icon
	var fx := text_x + 40
	var fy := body.position.y + 110
	draw_rect(Rect2(fx, fy, 30, 22), Color(0.82, 0.68, 0.22))
	draw_rect(Rect2(fx, fy - 5, 18, 5), Color(0.82, 0.68, 0.22))
	draw_rect(Rect2(fx, fy, 30, 22), Color(0.6, 0.5, 0.15), false, 1.0)

	_draw_xp_button(Rect2(body.end.x - 130, body.end.y - 26, 60, 20), "Next >", true)
	_draw_xp_button(Rect2(body.end.x - 65, body.end.y - 26, 60, 20), "Cancel")


func _draw_next(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(15, 5, w - 30, h - 10), "CoolApp 2.0 Setup")

	# Sidebar
	var sidebar_w := 60.0
	for i in range(20):
		var t := float(i) / 20
		var sy := body.position.y + t * body.size.y
		var sh := body.size.y / 20.0 + 1
		draw_rect(Rect2(body.position.x, sy, sidebar_w, sh), Color(0.08, 0.20, 0.55).lerp(Color(0.15, 0.40, 0.85), t))

	var text_x := body.position.x + sidebar_w + 6
	_draw_text("Ready to Install", Vector2(text_x, body.position.y + 16), 11, Color(0.0, 0.0, 0.0))
	_draw_text("Setup will install CoolApp 2.0", Vector2(text_x, body.position.y + 36), 9, Color(0.3, 0.3, 0.3))
	_draw_text("with the following settings:", Vector2(text_x, body.position.y + 50), 9, Color(0.3, 0.3, 0.3))

	# Summary
	var summary_y := body.position.y + 68
	var items := [
		"  CoolApp Core",
		"  Documentation",
		"  Sample Files",
		"  Desktop Shortcut",
	]
	for i in range(items.size()):
		var iy := summary_y + float(i) * 16
		# Checkmark
		draw_rect(Rect2(text_x + 2, iy - 2, 12, 12), Color(1.0, 1.0, 1.0))
		draw_rect(Rect2(text_x + 2, iy - 2, 12, 12), Color(0.4, 0.4, 0.4), false, 1.0)
		draw_line(Vector2(text_x + 5, iy + 4), Vector2(text_x + 7, iy + 7), Color(0.0, 0.5, 0.0), 1.5)
		draw_line(Vector2(text_x + 7, iy + 7), Vector2(text_x + 12, iy + 1), Color(0.0, 0.5, 0.0), 1.5)
		_draw_text(items[i], Vector2(text_x + 16, iy + 9), 9, Color(0.0, 0.0, 0.0))

	_draw_xp_button(Rect2(body.end.x - 130, body.end.y - 26, 60, 20), "Install", true)
	_draw_xp_button(Rect2(body.end.x - 65, body.end.y - 26, 60, 20), "Cancel")


func _draw_installing(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(15, 5, w - 30, h - 10), "CoolApp 2.0 Setup")

	# Sidebar
	var sidebar_w := 60.0
	for i in range(20):
		var t := float(i) / 20
		var sy := body.position.y + t * body.size.y
		var sh := body.size.y / 20.0 + 1
		draw_rect(Rect2(body.position.x, sy, sidebar_w, sh), Color(0.08, 0.20, 0.55).lerp(Color(0.15, 0.40, 0.85), t))

	var text_x := body.position.x + sidebar_w + 6
	_draw_text("Installing...", Vector2(text_x, body.position.y + 16), 11, Color(0.0, 0.0, 0.0))
	_draw_text("Please wait while CoolApp 2.0", Vector2(text_x, body.position.y + 36), 9, Color(0.3, 0.3, 0.3))
	_draw_text("is being installed.", Vector2(text_x, body.position.y + 50), 9, Color(0.3, 0.3, 0.3))

	# Progress bar
	var bar_w := body.size.x - sidebar_w - 16
	_draw_progress_bar(Rect2(text_x, body.position.y + 65, bar_w, 16), _wait_progress)

	# Percentage
	var pct := int(_wait_progress * 100.0)
	_draw_centered_text("%d%%" % pct, Vector2(text_x + bar_w / 2, body.position.y + 95), 11, Color(0.0, 0.0, 0.0))

	# Current file (scrolling)
	var file_names := ["coolapp.exe", "readme.txt", "data.dll", "config.ini", "help.chm", "uninstall.exe"]
	var file_idx := int(_wait_progress * (file_names.size() - 1))
	file_idx = clampi(file_idx, 0, file_names.size() - 1)
	_draw_text("Extracting: " + file_names[file_idx], Vector2(text_x, body.position.y + 110), 8, Color(0.4, 0.4, 0.4))


func _draw_finish(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(15, 5, w - 30, h - 10), "CoolApp 2.0 Setup")

	# Sidebar
	var sidebar_w := 60.0
	for i in range(20):
		var t := float(i) / 20
		var sy := body.position.y + t * body.size.y
		var sh := body.size.y / 20.0 + 1
		draw_rect(Rect2(body.position.x, sy, sidebar_w, sh), Color(0.08, 0.20, 0.55).lerp(Color(0.15, 0.40, 0.85), t))

	var text_x := body.position.x + sidebar_w + 6
	_draw_text("Installation Complete!", Vector2(text_x, body.position.y + 18), 12, Color(0.0, 0.55, 0.0))
	_draw_text("CoolApp 2.0 has been", Vector2(text_x, body.position.y + 38), 10, Color(0.0, 0.0, 0.0))
	_draw_text("successfully installed.", Vector2(text_x, body.position.y + 52), 10, Color(0.0, 0.0, 0.0))

	# Green checkmark
	var cx := text_x + 60
	var cy := body.position.y + 85
	draw_circle(Vector2(cx, cy), 20, Color(0.2, 0.7, 0.2, 0.2))
	draw_line(Vector2(cx - 12, cy), Vector2(cx - 4, cy + 10), Color(0.15, 0.65, 0.15), 3.0)
	draw_line(Vector2(cx - 4, cy + 10), Vector2(cx + 14, cy - 10), Color(0.15, 0.65, 0.15), 3.0)

	_draw_xp_button(Rect2(body.end.x - 70, body.end.y - 26, 60, 20), "Finish", true)
