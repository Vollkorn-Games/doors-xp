extends "res://scripts/tasks/task_visual.gd"

## Blue Screen Fix visual: BSOD → Safe Mode → Device Manager → fix driver → reboot.
## Steps: Don't Panic (Space) → Safe Mode (F) → Booting (wait) → Device Manager (D) →
##        Uninstall Driver (U) → Reinstall (I) → Installing (wait) → Reboot (R) → Verify (Enter)


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	match _step_index:
		0: _draw_bsod(w, h)
		1: _draw_boot_menu(w, h)
		2: _draw_booting(w, h)
		3: _draw_device_manager(w, h)
		4: _draw_uninstall_driver(w, h)
		5: _draw_reinstall_driver(w, h)
		6: _draw_installing_driver(w, h)
		7: _draw_reboot(w, h)
		8: _draw_verify(w, h)
		_: _draw_bsod(w, h)


func _draw_bsod(w: float, h: float) -> void:
	# Full blue screen of death
	draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.0, 0.68))

	var cx := w / 2.0
	var y := 12.0

	_draw_centered_text("Windows", Vector2(cx, y), 12, Color(0.68, 0.68, 0.68))
	y += 22
	_draw_text("A problem has been detected and Windows has", Vector2(10, y), 9, Color(1.0, 1.0, 1.0))
	y += 14
	_draw_text("been shut down to prevent damage to your computer.", Vector2(10, y), 9, Color(1.0, 1.0, 1.0))
	y += 22
	_draw_text("IRQL_NOT_LESS_OR_EQUAL", Vector2(10, y), 10, Color(1.0, 1.0, 1.0))
	y += 22
	_draw_text("If this is the first time you've seen this", Vector2(10, y), 8, Color(1.0, 1.0, 1.0))
	y += 12
	_draw_text("Stop error screen, restart your computer.", Vector2(10, y), 8, Color(1.0, 1.0, 1.0))
	y += 22
	_draw_text("Technical information:", Vector2(10, y), 8, Color(1.0, 1.0, 1.0))
	y += 14
	_draw_text("*** STOP: 0x0000000A (0x00000028,0x00000002,", Vector2(10, y), 8, Color(1.0, 1.0, 1.0))
	y += 12
	_draw_text("    0x00000000,0x804E3B92)", Vector2(10, y), 8, Color(1.0, 1.0, 1.0))
	y += 22

	# Memory dump progress
	var dump_pct := 0
	if _is_waiting:
		dump_pct = int(_wait_progress * 100)
	_draw_text("Physical memory dump: %d%%" % dump_pct, Vector2(10, y), 8, Color(1.0, 1.0, 1.0))


func _draw_boot_menu(w: float, h: float) -> void:
	# Black background with white text boot menu
	draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.0, 0.0))

	var y := 12.0
	_draw_centered_text("Windows Advanced Options Menu", Vector2(w / 2, y), 11, Color(1.0, 1.0, 1.0))
	y += 20
	_draw_text("Please select an option:", Vector2(10, y), 9, Color(0.7, 0.7, 0.7))
	y += 24

	var options := [
		["Safe Mode", true],
		["Safe Mode with Networking", false],
		["Safe Mode with Command Prompt", false],
		["", false],
		["Enable VGA Mode", false],
		["Last Known Good Configuration", false],
		["Start Windows Normally", false],
	]
	for i in range(options.size()):
		if options[i][0] == "":
			y += 10
			continue
		if options[i][1]:
			draw_rect(Rect2(20, y - 3, w - 40, 16), Color(0.7, 0.7, 0.7))
			_draw_text(options[i][0], Vector2(24, y + 10), 9, Color(0.0, 0.0, 0.0))
		else:
			_draw_text(options[i][0], Vector2(24, y + 10), 9, Color(0.7, 0.7, 0.7))
		y += 16

	y += 16
	_draw_text("Use arrow keys to highlight, Enter to select.", Vector2(10, y), 8, Color(0.5, 0.5, 0.5))


func _draw_booting(w: float, h: float) -> void:
	# Safe Mode loading screen
	draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.0, 0.0))

	var cx := w / 2.0
	var cy := h * 0.3

	# Windows logo (simplified)
	var flag_size := 12.0
	draw_rect(Rect2(cx - flag_size - 1, cy - flag_size - 1, flag_size, flag_size), Color(0.9, 0.2, 0.15))
	draw_rect(Rect2(cx + 1, cy - flag_size - 1, flag_size, flag_size), Color(0.2, 0.7, 0.2))
	draw_rect(Rect2(cx - flag_size - 1, cy + 1, flag_size, flag_size), Color(0.15, 0.4, 0.85))
	draw_rect(Rect2(cx + 1, cy + 1, flag_size, flag_size), Color(0.95, 0.75, 0.1))

	_draw_centered_text("Windows is starting up...", Vector2(cx, cy + 30), 10, Color(1.0, 1.0, 1.0))

	# Loading bar
	if _is_waiting:
		_draw_progress_bar(Rect2(cx - 80, cy + 45, 160, 10), _wait_progress, Color(0.3, 0.6, 1.0))

	# Safe Mode watermark
	_draw_text("Safe Mode", Vector2(4, 10), 9, Color(1.0, 1.0, 1.0))
	_draw_text("Safe Mode", Vector2(w - 70, 10), 9, Color(1.0, 1.0, 1.0))
	_draw_text("Safe Mode", Vector2(4, h - 14), 9, Color(1.0, 1.0, 1.0))
	_draw_text("Safe Mode", Vector2(w - 70, h - 14), 9, Color(1.0, 1.0, 1.0))


func _draw_device_manager(w: float, h: float) -> void:
	# Safe Mode desktop (low-res feel) with Device Manager
	draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.0, 0.0))  # Black desktop (safe mode)

	# "Safe Mode" watermarks
	_draw_text("Safe Mode", Vector2(4, 10), 8, Color(1.0, 1.0, 1.0))

	var body := _draw_mini_window(Rect2(12, 18, w - 24, h - 24), "Device Manager")

	# Device tree
	var tree_rect := Rect2(body.position.x + 4, body.position.y + 4, body.size.x - 8, body.size.y - 8)
	_draw_sunken_panel(tree_rect)

	var devices := [
		[0, "USER-PC", false],
		[1, "Computer", false],
		[1, "Disk drives", false],
		[1, "Display adapters", false],
		[2, "Bad Display Driver v6.66", true],
		[1, "Keyboards", false],
		[1, "Mice and pointing devices", false],
		[1, "Network adapters", false],
		[1, "Sound, video and game", false],
	]
	for i in range(devices.size()):
		var dy := tree_rect.position.y + 6 + float(i) * 15
		var indent: float = float(devices[i][0]) * 14
		var has_warning: bool = devices[i][2]

		if has_warning:
			# Yellow warning triangle
			var tx := tree_rect.position.x + 4 + indent
			var tri_pts := PackedVector2Array([
				Vector2(tx + 5, dy - 1),
				Vector2(tx, dy + 9),
				Vector2(tx + 10, dy + 9),
			])
			draw_polygon(tri_pts, PackedColorArray([Color(1.0, 0.85, 0.0), Color(1.0, 0.85, 0.0), Color(1.0, 0.85, 0.0)]))
			_draw_centered_text("!", Vector2(tx + 5, dy + 6), 8, Color(0.0, 0.0, 0.0))
			_draw_text(devices[i][1], Vector2(tx + 14, dy + 10), 8, Color(0.6, 0.0, 0.0))
		else:
			_draw_text(devices[i][1], Vector2(tree_rect.position.x + 6 + indent, dy + 10), 8, Color(0.0, 0.0, 0.0))


func _draw_uninstall_driver(w: float, h: float) -> void:
	draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.0, 0.0))
	_draw_text("Safe Mode", Vector2(4, 10), 8, Color(1.0, 1.0, 1.0))

	var body := _draw_mini_window(Rect2(12, 18, w - 24, h - 24), "Device Manager")
	var tree_rect := Rect2(body.position.x + 4, body.position.y + 4, body.size.x - 8, body.size.y - 8)
	_draw_sunken_panel(tree_rect)

	# Show the bad driver selected with context menu
	var dy := tree_rect.position.y + 6
	_draw_text("USER-PC", Vector2(tree_rect.position.x + 6, dy + 10), 8, Color(0.0, 0.0, 0.0))
	dy += 15
	_draw_text("  Display adapters", Vector2(tree_rect.position.x + 6, dy + 10), 8, Color(0.0, 0.0, 0.0))
	dy += 15
	# Selected driver
	draw_rect(Rect2(tree_rect.position.x + 24, dy - 2, tree_rect.size.x - 28, 16), Color(0.2, 0.4, 0.8))
	_draw_text("Bad Display Driver v6.66", Vector2(tree_rect.position.x + 28, dy + 10), 8, Color(1.0, 1.0, 1.0))

	# Right-click context menu
	var menu_x := tree_rect.position.x + 80
	var menu_y := dy + 14
	var menu_items := ["Update Driver...", "Disable", "Uninstall", "---", "Properties"]
	draw_rect(Rect2(menu_x, menu_y, 100, float(menu_items.size()) * 16 + 4), Color(1.0, 1.0, 1.0))
	draw_rect(Rect2(menu_x, menu_y, 100, float(menu_items.size()) * 16 + 4), Color(0.5, 0.5, 0.5), false, 1.0)
	for i in range(menu_items.size()):
		var iy := menu_y + 2 + float(i) * 16
		if menu_items[i] == "---":
			draw_line(Vector2(menu_x + 4, iy + 8), Vector2(menu_x + 96, iy + 8), Color(0.7, 0.7, 0.7), 1.0)
		elif menu_items[i] == "Uninstall":
			draw_rect(Rect2(menu_x + 2, iy, 96, 16), Color(0.2, 0.4, 0.8))
			_draw_text(menu_items[i], Vector2(menu_x + 8, iy + 12), 9, Color(1.0, 1.0, 1.0))
		else:
			_draw_text(menu_items[i], Vector2(menu_x + 8, iy + 12), 9, Color(0.0, 0.0, 0.0))


func _draw_reinstall_driver(w: float, h: float) -> void:
	draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.0, 0.0))
	_draw_text("Safe Mode", Vector2(4, 10), 8, Color(1.0, 1.0, 1.0))

	var body := _draw_mini_window(Rect2(25, 25, w - 50, h - 50), "Update Driver - Display Adapter")

	_draw_text("Install driver from:", Vector2(body.position.x + 8, body.position.y + 20), 10, Color(0.0, 0.0, 0.0))

	# Radio options
	var ry := body.position.y + 35
	draw_circle(Vector2(body.position.x + 16, ry + 6), 5, Color(1.0, 1.0, 1.0))
	draw_circle(Vector2(body.position.x + 16, ry + 6), 5, Color(0.4, 0.4, 0.4), false, 1.0)
	_draw_text("Search automatically", Vector2(body.position.x + 26, ry + 11), 9, Color(0.0, 0.0, 0.0))

	ry += 22
	draw_circle(Vector2(body.position.x + 16, ry + 6), 5, Color(1.0, 1.0, 1.0))
	draw_circle(Vector2(body.position.x + 16, ry + 6), 5, Color(0.4, 0.4, 0.4), false, 1.0)
	draw_circle(Vector2(body.position.x + 16, ry + 6), 2, Color(0.0, 0.0, 0.0))
	_draw_text("Install from disk", Vector2(body.position.x + 26, ry + 11), 9, Color(0.0, 0.0, 0.0))

	# Path
	var path_rect := Rect2(body.position.x + 30, ry + 18, body.size.x - 80, 16)
	_draw_sunken_panel(path_rect)
	_draw_text("D:\\Drivers\\Display", Vector2(path_rect.position.x + 4, path_rect.position.y + 12), 8, Color(0.0, 0.0, 0.0))

	_draw_xp_button(Rect2(body.end.x - 70, body.end.y - 26, 60, 20), "Install", true)
	_draw_xp_button(Rect2(body.end.x - 140, body.end.y - 26, 60, 20), "Cancel")


func _draw_installing_driver(w: float, h: float) -> void:
	draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.0, 0.0))
	_draw_text("Safe Mode", Vector2(4, 10), 8, Color(1.0, 1.0, 1.0))

	var body := _draw_mini_window(Rect2(30, 30, w - 60, h - 60), "Installing Driver...")

	_draw_text("Installing display driver...", Vector2(body.position.x + 8, body.position.y + 20), 10, Color(0.0, 0.0, 0.0))
	_draw_text("Please wait.", Vector2(body.position.x + 8, body.position.y + 38), 9, Color(0.3, 0.3, 0.3))

	# Progress bar
	_draw_progress_bar(Rect2(body.position.x + 8, body.position.y + 55, body.size.x - 16, 14), _wait_progress)

	var pct := int(_wait_progress * 100.0)
	_draw_centered_text("%d%%" % pct, Vector2(body.position.x + body.size.x / 2, body.position.y + 82), 10, Color(0.0, 0.0, 0.0))


func _draw_reboot(w: float, h: float) -> void:
	# Shutdown dialog
	draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.0, 0.0, 0.5))  # Dimmed

	var body := _draw_mini_window(Rect2(40, 30, w - 80, h - 60), "Shut Down Windows")

	_draw_text("What do you want the", Vector2(body.position.x + 45, body.position.y + 20), 10, Color(0.0, 0.0, 0.0))
	_draw_text("computer to do?", Vector2(body.position.x + 45, body.position.y + 34), 10, Color(0.0, 0.0, 0.0))

	# Windows flag icon (left side)
	var fx := body.position.x + 15
	var fy := body.position.y + 20
	draw_rect(Rect2(fx, fy, 10, 10), Color(0.9, 0.2, 0.15))
	draw_rect(Rect2(fx + 11, fy, 10, 10), Color(0.2, 0.7, 0.2))
	draw_rect(Rect2(fx, fy + 11, 10, 10), Color(0.15, 0.4, 0.85))
	draw_rect(Rect2(fx + 11, fy + 11, 10, 10), Color(0.95, 0.75, 0.1))

	# Dropdown
	var dd_rect := Rect2(body.position.x + 10, body.position.y + 52, body.size.x - 20, 18)
	_draw_sunken_panel(dd_rect)
	_draw_text("Restart", Vector2(dd_rect.position.x + 6, dd_rect.position.y + 13), 10, Color(0.0, 0.0, 0.0))
	# Dropdown arrow
	var arr_x := dd_rect.end.x - 14
	draw_rect(Rect2(arr_x, dd_rect.position.y + 1, 13, 16), Color(0.88, 0.87, 0.84))
	var tri := PackedVector2Array([Vector2(arr_x + 3, dd_rect.position.y + 6), Vector2(arr_x + 11, dd_rect.position.y + 6), Vector2(arr_x + 7, dd_rect.position.y + 12)])
	draw_polygon(tri, PackedColorArray([Color(0.2, 0.2, 0.2), Color(0.2, 0.2, 0.2), Color(0.2, 0.2, 0.2)]))

	_draw_xp_button(Rect2(body.position.x + 10, body.end.y - 28, 60, 22), "OK", true)
	_draw_xp_button(Rect2(body.position.x + 80, body.end.y - 28, 60, 22), "Cancel")
	_draw_xp_button(Rect2(body.position.x + 150, body.end.y - 28, 60, 22), "Help")


func _draw_verify(w: float, h: float) -> void:
	# Normal desktop loading - system restored
	draw_rect(Rect2(0, 0, w, h), Color(0.22, 0.45, 0.73))  # XP blue desktop

	var cx := w / 2.0
	var cy := h * 0.35

	# Welcome text
	_draw_centered_text("Welcome", Vector2(cx, cy - 20), 16, Color(1.0, 1.0, 1.0))

	# Green checkmark
	draw_circle(Vector2(cx, cy + 15), 22, Color(0.2, 0.7, 0.2, 0.3))
	draw_line(Vector2(cx - 14, cy + 15), Vector2(cx - 5, cy + 26), Color(0.15, 0.75, 0.15), 4.0)
	draw_line(Vector2(cx - 5, cy + 26), Vector2(cx + 16, cy + 2), Color(0.15, 0.75, 0.15), 4.0)

	_draw_centered_text("System Restored!", Vector2(cx, cy + 50), 12, Color(1.0, 1.0, 1.0))
	_draw_centered_text("Driver updated successfully.", Vector2(cx, cy + 68), 9, Color(0.8, 0.9, 1.0))

	# Fake taskbar at bottom
	draw_rect(Rect2(0, h - 16, w, 16), Color(0.13, 0.38, 0.85))
	draw_rect(Rect2(2, h - 14, 40, 12), Color(0.21, 0.62, 0.17))
	_draw_text("start", Vector2(10, h - 4), 8, Color(1.0, 1.0, 1.0))
