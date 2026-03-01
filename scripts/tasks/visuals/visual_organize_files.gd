extends "res://scripts/tasks/task_visual.gd"

## Organize Files visual: Windows Explorer with messy files → sort into folders.
## Steps: Open Explorer → Select All → Cut → Open Folder → Paste → Moving (wait) → Confirm

# File icons data: [name, extension_color]
const FILES := [
	["budget.xls", Color(0.15, 0.55, 0.15)],
	["photo.jpg", Color(0.75, 0.45, 0.15)],
	["notes.txt", Color(0.5, 0.5, 0.5)],
	["report.doc", Color(0.15, 0.35, 0.75)],
	["data.csv", Color(0.15, 0.55, 0.15)],
	["logo.bmp", Color(0.75, 0.45, 0.15)],
	["todo.txt", Color(0.5, 0.5, 0.5)],
	["memo.doc", Color(0.15, 0.35, 0.75)],
]


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	draw_rect(Rect2(0, 0, w, h), Color(0.93, 0.92, 0.87))

	match _step_index:
		0: _draw_messy_explorer(w, h, false, false)
		1: _draw_messy_explorer(w, h, true, false)
		2: _draw_messy_explorer(w, h, true, true)
		3: _draw_open_folder(w, h)
		4: _draw_paste_files(w, h)
		5: _draw_moving(w, h)
		6: _draw_complete(w, h)
		_: _draw_messy_explorer(w, h, false, false)


func _draw_messy_explorer(w: float, h: float, selected: bool, cut: bool) -> void:
	var body := _draw_mini_window(Rect2(8, 3, w - 16, h - 6), "C:\\Desktop")

	# Address bar
	var addr_rect := Rect2(body.position.x + 4, body.position.y + 4, body.size.x - 8, 16)
	_draw_sunken_panel(addr_rect)
	_draw_text("C:\\Documents and Settings\\User\\Desktop", Vector2(addr_rect.position.x + 4, addr_rect.position.y + 12), 8, Color(0.0, 0.0, 0.0))

	# File area
	var file_area := Rect2(body.position.x + 4, body.position.y + 24, body.size.x - 8, body.size.y - 28)
	_draw_sunken_panel(file_area)

	# Draw files scattered
	for i in range(FILES.size()):
		@warning_ignore("integer_division")
		var col := i % 4
		@warning_ignore("integer_division")
		var row := i / 4
		var fx: float = file_area.position.x + 10 + float(col) * 70
		var fy: float = file_area.position.y + 10 + float(row) * 55

		var alpha := 0.4 if cut else 1.0

		# Selection highlight
		if selected:
			draw_rect(Rect2(fx - 4, fy - 2, 60, 48), Color(0.2, 0.4, 0.8, 0.2 * alpha))

		# File icon
		var icon_rect := Rect2(fx + 12, fy, 24, 28)
		draw_rect(icon_rect, Color(1.0, 1.0, 1.0, alpha))
		draw_rect(icon_rect, Color(0.5, 0.5, 0.5, alpha), false, 1.0)
		# Extension color bar
		draw_rect(Rect2(fx + 14, fy + 16, 20, 10), Color(FILES[i][1], alpha))

		# Filename
		var name_color := Color(0.0, 0.0, 0.0, alpha)
		if selected:
			name_color = Color(1.0, 1.0, 1.0, alpha) if not cut else Color(0.5, 0.5, 0.5, alpha)
		_draw_centered_text(FILES[i][0], Vector2(fx + 24, fy + 38), 8, name_color)


func _draw_open_folder(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(8, 3, w - 16, h - 6), "C:\\Desktop")

	# Split view: folder tree | file area
	var tree_w := 100.0
	var tree_rect := Rect2(body.position.x + 4, body.position.y + 4, tree_w, body.size.y - 8)
	_draw_sunken_panel(tree_rect)

	# Folder tree
	var folders := [
		[0, "Desktop"],
		[0, "My Documents"],
		[1, "Work"],
		[1, "Personal"],
		[1, "Projects"],
		[0, "My Computer"],
	]
	for i in range(folders.size()):
		var fy := tree_rect.position.y + 6 + float(i) * 18
		var indent: float = float(folders[i][0]) * 14
		var fname: String = folders[i][1]
		var is_target := fname == "Work"

		# Folder icon
		draw_rect(Rect2(tree_rect.position.x + 6 + indent, fy, 12, 9), Color(0.82, 0.68, 0.22))
		draw_rect(Rect2(tree_rect.position.x + 6 + indent, fy - 3, 7, 3), Color(0.82, 0.68, 0.22))

		if is_target:
			draw_rect(Rect2(tree_rect.position.x + 4 + indent, fy - 4, tree_w - 8 - indent, 18), Color(0.2, 0.4, 0.8, 0.2))
			_draw_text(fname, Vector2(tree_rect.position.x + 22 + indent, fy + 10), 9, Color(0.0, 0.0, 0.8))
		else:
			_draw_text(fname, Vector2(tree_rect.position.x + 22 + indent, fy + 10), 9, Color(0.0, 0.0, 0.0))

	# Right panel showing target folder (empty)
	var right := Rect2(body.position.x + tree_w + 8, body.position.y + 4, body.size.x - tree_w - 12, body.size.y - 8)
	_draw_sunken_panel(right)
	_draw_centered_text("(empty)", Vector2(right.position.x + right.size.x / 2, right.position.y + right.size.y / 2), 11, Color(0.5, 0.5, 0.5))


func _draw_paste_files(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(8, 3, w - 16, h - 6), "C:\\My Documents\\Work")

	# Address bar
	var addr_rect := Rect2(body.position.x + 4, body.position.y + 4, body.size.x - 8, 16)
	_draw_sunken_panel(addr_rect)
	_draw_text("C:\\My Documents\\Work", Vector2(addr_rect.position.x + 4, addr_rect.position.y + 12), 8, Color(0.0, 0.0, 0.0))

	# File area with files appearing neatly
	var file_area := Rect2(body.position.x + 4, body.position.y + 24, body.size.x - 8, body.size.y - 28)
	_draw_sunken_panel(file_area)

	for i in range(FILES.size()):
		@warning_ignore("integer_division")
		var col := i % 4
		@warning_ignore("integer_division")
		var row := i / 4
		var fx: float = file_area.position.x + 10 + float(col) * 70
		var fy: float = file_area.position.y + 10 + float(row) * 55

		# File icon (appearing)
		var icon_rect := Rect2(fx + 12, fy, 24, 28)
		draw_rect(icon_rect, Color(1.0, 1.0, 1.0))
		draw_rect(icon_rect, Color(0.5, 0.5, 0.5), false, 1.0)
		draw_rect(Rect2(fx + 14, fy + 16, 20, 10), FILES[i][1])
		_draw_centered_text(FILES[i][0], Vector2(fx + 24, fy + 38), 8, Color(0.0, 0.0, 0.0))


func _draw_moving(w: float, h: float) -> void:
	# XP file copy dialog
	var body := _draw_mini_window(Rect2(30, 15, w - 60, h - 30), "Moving...")

	_draw_text("Moving files to 'Work'", Vector2(body.position.x + 8, body.position.y + 18), 10, Color(0.0, 0.0, 0.0))

	# Flying paper animation
	var paper_x := body.position.x + 30 + _wait_progress * (body.size.x - 80)
	var paper_y := body.position.y + 40

	# Source folder
	draw_rect(Rect2(body.position.x + 10, paper_y - 5, 25, 18), Color(0.82, 0.68, 0.22))
	draw_rect(Rect2(body.position.x + 10, paper_y - 8, 15, 3), Color(0.82, 0.68, 0.22))

	# Destination folder
	draw_rect(Rect2(body.end.x - 35, paper_y - 5, 25, 18), Color(0.82, 0.68, 0.22))
	draw_rect(Rect2(body.end.x - 35, paper_y - 8, 15, 3), Color(0.82, 0.68, 0.22))

	# Flying paper
	var paper_arc_y := paper_y - 15 - sin(_wait_progress * PI) * 20
	draw_rect(Rect2(paper_x - 6, paper_arc_y, 12, 14), Color(1.0, 1.0, 1.0))
	draw_rect(Rect2(paper_x - 6, paper_arc_y, 12, 14), Color(0.5, 0.5, 0.5), false, 1.0)

	# Progress bar
	_draw_progress_bar(Rect2(body.position.x + 8, paper_y + 25, body.size.x - 16, 14), _wait_progress)

	var files_moved := int(_wait_progress * FILES.size())
	_draw_text("Files moved: %d of %d" % [files_moved, FILES.size()], Vector2(body.position.x + 8, paper_y + 48), 9, Color(0.4, 0.4, 0.4))

	_draw_xp_button(Rect2(body.end.x - 70, body.end.y - 28, 60, 22), "Cancel")


func _draw_complete(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(8, 3, w - 16, h - 6), "C:\\My Documents\\Work")

	# Address bar
	var addr_rect := Rect2(body.position.x + 4, body.position.y + 4, body.size.x - 8, 16)
	_draw_sunken_panel(addr_rect)
	_draw_text("C:\\My Documents\\Work", Vector2(addr_rect.position.x + 4, addr_rect.position.y + 12), 8, Color(0.0, 0.0, 0.0))

	# Files neatly arranged
	var file_area := Rect2(body.position.x + 4, body.position.y + 24, body.size.x - 8, body.size.y - 28)
	_draw_sunken_panel(file_area)

	for i in range(FILES.size()):
		@warning_ignore("integer_division")
		var col := i % 4
		@warning_ignore("integer_division")
		var row := i / 4
		var fx: float = file_area.position.x + 10 + float(col) * 70
		var fy: float = file_area.position.y + 10 + float(row) * 55

		var icon_rect := Rect2(fx + 12, fy, 24, 28)
		draw_rect(icon_rect, Color(1.0, 1.0, 1.0))
		draw_rect(icon_rect, Color(0.5, 0.5, 0.5), false, 1.0)
		draw_rect(Rect2(fx + 14, fy + 16, 20, 10), FILES[i][1])
		_draw_centered_text(FILES[i][0], Vector2(fx + 24, fy + 38), 8, Color(0.0, 0.0, 0.0))

	# Green checkmark overlay
	var cx := w / 2.0
	var cy := h * 0.5
	draw_circle(Vector2(cx, cy), 22, Color(0.2, 0.7, 0.2, 0.15))
	draw_line(Vector2(cx - 12, cy), Vector2(cx - 4, cy + 10), Color(0.15, 0.65, 0.15, 0.6), 3.0)
	draw_line(Vector2(cx - 4, cy + 10), Vector2(cx + 14, cy - 10), Color(0.15, 0.65, 0.15, 0.6), 3.0)
