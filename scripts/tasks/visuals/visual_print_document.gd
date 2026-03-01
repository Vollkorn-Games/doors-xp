extends "res://scripts/tasks/task_visual.gd"

## Print Document visual: Word-like document → File menu → Print dialog → Printing.
## Steps: Open Doc → File Menu → Print → Select Printer → Confirm → Spool (wait) → Print (wait) → Collect


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	draw_rect(Rect2(0, 0, w, h), Color(0.93, 0.92, 0.87))

	match _step_index:
		0: _draw_open_document(w, h)
		1: _draw_file_menu(w, h)
		2: _draw_print_menu_item(w, h)
		3: _draw_select_printer(w, h)
		4: _draw_confirm_print(w, h)
		5: _draw_spooling(w, h)
		6: _draw_printing(w, h)
		7: _draw_collect(w, h)
		_: _draw_open_document(w, h)


func _draw_open_document(w: float, h: float) -> void:
	# Document icon on desktop
	var cx := w / 2.0
	var cy := h * 0.35

	# Document icon (large)
	var doc_rect := Rect2(cx - 25, cy - 30, 50, 60)
	draw_rect(doc_rect, Color(1.0, 1.0, 1.0))
	draw_rect(doc_rect, Color(0.3, 0.3, 0.3), false, 1.5)
	# Dog-ear
	var ear_pts := PackedVector2Array([
		Vector2(cx + 15, cy - 30),
		Vector2(cx + 25, cy - 30),
		Vector2(cx + 25, cy - 20),
	])
	draw_polygon(ear_pts, PackedColorArray([Color(0.85, 0.85, 0.85), Color(0.85, 0.85, 0.85), Color(0.85, 0.85, 0.85)]))
	draw_polyline(PackedVector2Array([Vector2(cx + 15, cy - 30), Vector2(cx + 15, cy - 20), Vector2(cx + 25, cy - 20)]), Color(0.3, 0.3, 0.3), 1.0)
	# "W" icon for Word
	_draw_centered_text("W", Vector2(cx - 8, cy - 5), 20, Color(0.15, 0.35, 0.75))
	# Text lines
	for i in range(3):
		var ly := cy + 8 + float(i) * 6
		draw_line(Vector2(cx - 15, ly), Vector2(cx + 15, ly), Color(0.5, 0.5, 0.5, 0.4), 1.0)

	# Filename
	_draw_centered_text("quarterly_report.doc", Vector2(cx, cy + 45), 11, Color(0.0, 0.0, 0.0))

	# Cursor arrow pointing at document
	var ax := cx + 30
	var ay := cy + 5
	var arrow_pts := PackedVector2Array([
		Vector2(ax, ay),
		Vector2(ax, ay + 16),
		Vector2(ax + 4, ay + 12),
		Vector2(ax + 8, ay + 18),
		Vector2(ax + 11, ay + 16),
		Vector2(ax + 7, ay + 10),
		Vector2(ax + 12, ay + 10),
	])
	draw_polygon(arrow_pts, PackedColorArray([Color(1,1,1), Color(1,1,1), Color(1,1,1), Color(1,1,1), Color(1,1,1), Color(1,1,1), Color(1,1,1)]))
	draw_polyline(PackedVector2Array([arrow_pts[0], arrow_pts[1], arrow_pts[2], arrow_pts[3], arrow_pts[4], arrow_pts[5], arrow_pts[6], arrow_pts[0]]), Color(0,0,0), 1.0)


func _draw_file_menu(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(15, 5, w - 30, h - 10), "quarterly_report.doc - Microsoft Word")

	# Menu bar inside the mini window
	var menus := ["File", "Edit", "View", "Insert", "Format"]
	for i in range(menus.size()):
		var mx: float = body.position.x + 6 + float(i) * 42
		var my := body.position.y + 3
		if menus[i] == "File":
			draw_rect(Rect2(mx - 2, my - 2, 32, 16), Color(0.2, 0.4, 0.8))
			_draw_text(menus[i], Vector2(mx, my + 10), 10, Color(1.0, 1.0, 1.0))
		else:
			_draw_text(menus[i], Vector2(mx, my + 10), 10, Color(0.0, 0.0, 0.0))

	# Dropdown
	var dd_x := body.position.x + 4
	var dd_y := body.position.y + 18
	var dd_items := ["New...", "Open...", "Close", "Save", "Save As...", "---", "Page Setup...", "Print Preview", "Print...", "---", "Exit"]
	draw_rect(Rect2(dd_x, dd_y, 120, float(dd_items.size()) * 18 + 6), Color(1.0, 1.0, 1.0))
	draw_rect(Rect2(dd_x, dd_y, 120, float(dd_items.size()) * 18 + 6), Color(0.5, 0.5, 0.5), false, 1.0)
	for i in range(dd_items.size()):
		var iy := dd_y + 3 + float(i) * 18
		if dd_items[i] == "---":
			draw_line(Vector2(dd_x + 4, iy + 9), Vector2(dd_x + 116, iy + 9), Color(0.7, 0.7, 0.7), 1.0)
		else:
			_draw_text(dd_items[i], Vector2(dd_x + 8, iy + 14), 10, Color(0.0, 0.0, 0.0))


func _draw_print_menu_item(w: float, h: float) -> void:
	# Same as file menu but "Print..." is highlighted
	var body := _draw_mini_window(Rect2(15, 5, w - 30, h - 10), "quarterly_report.doc - Microsoft Word")

	# Menu bar
	var mx := body.position.x + 4
	draw_rect(Rect2(mx, body.position.y + 1, 32, 16), Color(0.2, 0.4, 0.8))
	_draw_text("File", Vector2(mx + 2, body.position.y + 13), 10, Color(1.0, 1.0, 1.0))

	# Dropdown with Print highlighted
	var dd_x := body.position.x + 4
	var dd_y := body.position.y + 18
	var dd_items := ["New...", "Open...", "Close", "Save", "Save As...", "---", "Page Setup...", "Print Preview", "Print...", "---", "Exit"]
	draw_rect(Rect2(dd_x, dd_y, 120, float(dd_items.size()) * 18 + 6), Color(1.0, 1.0, 1.0))
	draw_rect(Rect2(dd_x, dd_y, 120, float(dd_items.size()) * 18 + 6), Color(0.5, 0.5, 0.5), false, 1.0)
	for i in range(dd_items.size()):
		var iy := dd_y + 3 + float(i) * 18
		if dd_items[i] == "---":
			draw_line(Vector2(dd_x + 4, iy + 9), Vector2(dd_x + 116, iy + 9), Color(0.7, 0.7, 0.7), 1.0)
		elif dd_items[i] == "Print...":
			draw_rect(Rect2(dd_x + 2, iy, 116, 18), Color(0.2, 0.4, 0.8))
			_draw_text(dd_items[i], Vector2(dd_x + 8, iy + 14), 10, Color(1.0, 1.0, 1.0))
		else:
			_draw_text(dd_items[i], Vector2(dd_x + 8, iy + 14), 10, Color(0.0, 0.0, 0.0))


func _draw_select_printer(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(25, 10, w - 50, h - 20), "Print")

	# Printer section
	_draw_text("Select Printer:", Vector2(body.position.x + 8, body.position.y + 18), 10, Color(0.0, 0.0, 0.0))
	var list_rect := Rect2(body.position.x + 8, body.position.y + 24, body.size.x - 16, 60)
	_draw_sunken_panel(list_rect)

	# Printer entries
	var printers := ["Microsoft XPS Document Writer", "HP DeskJet 840C", "Fax"]
	for i in range(printers.size()):
		var py := list_rect.position.y + 2 + float(i) * 18
		if printers[i] == "HP DeskJet 840C":
			draw_rect(Rect2(list_rect.position.x + 2, py, list_rect.size.x - 4, 18), Color(0.2, 0.4, 0.8))
			# Printer icon
			draw_rect(Rect2(list_rect.position.x + 6, py + 3, 12, 10), Color(0.8, 0.8, 0.78))
			_draw_text(printers[i], Vector2(list_rect.position.x + 22, py + 14), 10, Color(1.0, 1.0, 1.0))
		else:
			draw_rect(Rect2(list_rect.position.x + 6, py + 3, 12, 10), Color(0.7, 0.7, 0.68))
			_draw_text(printers[i], Vector2(list_rect.position.x + 22, py + 14), 10, Color(0.0, 0.0, 0.0))

	# Copies
	_draw_text("Number of copies:", Vector2(body.position.x + 8, body.position.y + 100), 10, Color(0.0, 0.0, 0.0))
	_draw_sunken_panel(Rect2(body.position.x + 120, body.position.y + 88, 40, 18))
	_draw_text("3", Vector2(body.position.x + 132, body.position.y + 102), 11, Color(0.0, 0.0, 0.0))

	# Buttons
	_draw_xp_button(Rect2(body.end.x - 140, body.end.y - 30, 60, 22), "OK")
	_draw_xp_button(Rect2(body.end.x - 70, body.end.y - 30, 60, 22), "Cancel")


func _draw_confirm_print(w: float, h: float) -> void:
	# Same as select printer but OK highlighted
	var body := _draw_mini_window(Rect2(25, 10, w - 50, h - 20), "Print")

	_draw_text("Select Printer:", Vector2(body.position.x + 8, body.position.y + 18), 10, Color(0.0, 0.0, 0.0))
	var list_rect := Rect2(body.position.x + 8, body.position.y + 24, body.size.x - 16, 60)
	_draw_sunken_panel(list_rect)

	var printers := ["Microsoft XPS Document Writer", "HP DeskJet 840C", "Fax"]
	for i in range(printers.size()):
		var py := list_rect.position.y + 2 + float(i) * 18
		if printers[i] == "HP DeskJet 840C":
			draw_rect(Rect2(list_rect.position.x + 2, py, list_rect.size.x - 4, 18), Color(0.2, 0.4, 0.8))
			draw_rect(Rect2(list_rect.position.x + 6, py + 3, 12, 10), Color(0.8, 0.8, 0.78))
			_draw_text(printers[i], Vector2(list_rect.position.x + 22, py + 14), 10, Color(1.0, 1.0, 1.0))
		else:
			draw_rect(Rect2(list_rect.position.x + 6, py + 3, 12, 10), Color(0.7, 0.7, 0.68))
			_draw_text(printers[i], Vector2(list_rect.position.x + 22, py + 14), 10, Color(0.0, 0.0, 0.0))

	_draw_text("Number of copies:", Vector2(body.position.x + 8, body.position.y + 100), 10, Color(0.0, 0.0, 0.0))
	_draw_sunken_panel(Rect2(body.position.x + 120, body.position.y + 88, 40, 18))
	_draw_text("3", Vector2(body.position.x + 132, body.position.y + 102), 11, Color(0.0, 0.0, 0.0))

	# OK highlighted
	_draw_xp_button(Rect2(body.end.x - 140, body.end.y - 30, 60, 22), "OK", true)
	_draw_xp_button(Rect2(body.end.x - 70, body.end.y - 30, 60, 22), "Cancel")


func _draw_spooling(w: float, h: float) -> void:
	var cx := w / 2.0

	# Printer icon area
	var py := h * 0.2
	# Small printer icon
	_draw_printer_icon(cx, py, 1.5)

	# Status text
	_draw_centered_text("Sending to print spooler...", Vector2(cx, py + 45), 11, Color(0.3, 0.3, 0.3))
	_draw_centered_text("quarterly_report.doc", Vector2(cx, py + 62), 10, Color(0.5, 0.5, 0.5))

	# Progress bar
	var bar_rect := Rect2(cx - 120, py + 75, 240, 16)
	_draw_progress_bar(bar_rect, _wait_progress)

	var pct := int(_wait_progress * 100.0)
	_draw_centered_text("%d%%" % pct, Vector2(cx, py + 105), 10, Color(0.3, 0.3, 0.3))


func _draw_printing(w: float, h: float) -> void:
	var cx := w / 2.0
	var py := h * 0.15

	# Larger printer with paper coming out
	_draw_printer_icon(cx, py, 2.0)

	# Paper coming out (animated based on progress)
	var paper_h := 30.0 * _wait_progress
	if paper_h > 1.0:
		draw_rect(Rect2(cx - 12, py - 22 - paper_h, 24, paper_h), Color(1.0, 1.0, 1.0))
		draw_rect(Rect2(cx - 12, py - 22 - paper_h, 24, paper_h), Color(0.6, 0.6, 0.6), false, 1.0)
		# Text lines on paper
		for i in range(int(paper_h / 5)):
			var lly := py - 20 - paper_h + 4 + float(i) * 5
			if lly < py - 22:
				draw_line(Vector2(cx - 8, lly), Vector2(cx + 8, lly), Color(0.3, 0.3, 0.3, 0.3), 1.0)

	# Page counter
	var page := 1 + int(_wait_progress * 2.0)
	page = mini(page, 3)
	_draw_centered_text("Printing page %d of 3..." % page, Vector2(cx, py + 40), 11, Color(0.3, 0.3, 0.3))

	# Progress bar
	var bar_rect := Rect2(cx - 120, py + 55, 240, 16)
	_draw_progress_bar(bar_rect, _wait_progress)


func _draw_collect(w: float, h: float) -> void:
	var cx := w / 2.0
	var py := h * 0.15

	# Printer
	_draw_printer_icon(cx, py, 2.0)

	# Stack of 3 printed pages in tray
	for i in range(3):
		var offset := float(2 - i) * 3
		draw_rect(Rect2(cx - 14 + offset, py + 18 + float(i) * 2, 28, 20), Color(1.0, 1.0, 1.0))
		draw_rect(Rect2(cx - 14 + offset, py + 18 + float(i) * 2, 28, 20), Color(0.5, 0.5, 0.5), false, 1.0)
		# Text lines
		for j in range(3):
			var lly := py + 22 + float(i) * 2 + float(j) * 4
			draw_line(Vector2(cx - 10 + offset, lly), Vector2(cx + 10 + offset, lly), Color(0.3, 0.3, 0.3, 0.3), 1.0)

	# Hand cursor
	var hx := cx + 35
	var hy := py + 25
	draw_circle(Vector2(hx, hy), 6, Color(1.0, 0.9, 0.75))
	draw_rect(Rect2(hx - 4, hy, 8, 16), Color(1.0, 0.9, 0.75))
	draw_circle(Vector2(hx, hy), 6, Color(0.5, 0.4, 0.3), false, 1.0)

	_draw_centered_text("Printing complete!", Vector2(cx, py + 60), 12, Color(0.0, 0.55, 0.0))
	_draw_centered_text("Grab your pages", Vector2(cx, py + 78), 10, Color(0.3, 0.3, 0.3))


func _draw_printer_icon(cx: float, cy: float, s: float) -> void:
	# Simplified printer shape
	# Main body
	var body_w := 30.0 * s
	var body_h := 16.0 * s
	draw_rect(Rect2(cx - body_w / 2, cy - body_h / 2, body_w, body_h), Color(0.82, 0.82, 0.80))
	draw_rect(Rect2(cx - body_w / 2, cy - body_h / 2, body_w, body_h), Color(0.5, 0.5, 0.48), false, 1.0)
	# Paper input slot on top
	draw_rect(Rect2(cx - body_w * 0.35, cy - body_h / 2 - 4 * s, body_w * 0.7, 4 * s), Color(0.9, 0.9, 0.88))
	# Output tray
	draw_rect(Rect2(cx - body_w * 0.3, cy + body_h / 2, body_w * 0.6, 3 * s), Color(0.75, 0.75, 0.73))
	# LED
	draw_circle(Vector2(cx + body_w * 0.3, cy), 2.0 * s, Color(0.3, 0.8, 0.3))
