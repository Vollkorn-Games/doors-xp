extends "res://scripts/tasks/task_visual.gd"

## Defrag HDD visual: the iconic Windows XP disk defragmenter view.
## Steps: Open My Computer → Right-Click Drive → Properties → Tools Tab →
##        Analyzing... (wait) → Defragment Now → Defragmenting... (wait) → Close

# Block grid state
var _blocks: Array[int] = []  # 0=free, 1=used_ok, 2=fragmented, 3=system
const GRID_COLS := 28
const GRID_ROWS := 10
const TOTAL_BLOCKS := GRID_COLS * GRID_ROWS

# Colors matching real XP defrag
const COL_FREE := Color(1.0, 1.0, 1.0)
const COL_USED := Color(0.15, 0.35, 0.85)   # Blue = unfragmented
const COL_FRAG := Color(0.85, 0.15, 0.15)   # Red = fragmented
const COL_SYSTEM := Color(0.15, 0.65, 0.15)  # Green = system/unmovable
const COL_MOVED := Color(0.35, 0.68, 0.22)   # Green = just defragmented


func _ready() -> void:
	_generate_blocks()


func _generate_blocks() -> void:
	_blocks.clear()
	_blocks.resize(TOTAL_BLOCKS)
	# Generate a realistic-looking fragmented disk
	for i in range(TOTAL_BLOCKS):
		var r := randf()
		if i < 12:
			_blocks[i] = 3  # System files at start
		elif r < 0.15:
			_blocks[i] = 0  # Free
		elif r < 0.40:
			_blocks[i] = 2  # Fragmented
		else:
			_blocks[i] = 1  # Used OK


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	# Background
	draw_rect(Rect2(0, 0, w, h), Color(0.93, 0.92, 0.87))

	match _step_index:
		0: _draw_my_computer(w, h)
		1: _draw_right_click(w, h)
		2: _draw_properties(w, h)
		3: _draw_tools_tab(w, h)
		4: _draw_analyzing(w, h)
		5: _draw_defrag_button(w, h)
		6: _draw_defragmenting(w, h)
		7: _draw_complete(w, h)
		_: _draw_my_computer(w, h)


func _draw_my_computer(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "My Computer")

	# Drive icons
	var drives := [
		["C:", "Local Disk", Color(0.7, 0.7, 0.65), true],
		["D:", "CD-ROM", Color(0.75, 0.75, 0.72), false],
		["A:", "Floppy", Color(0.6, 0.6, 0.58), false],
	]
	for i in range(drives.size()):
		var dx: float = body.position.x + 30 + float(i) * 100
		var dy: float = body.position.y + 40
		# Drive icon (simplified)
		var drect := Rect2(dx - 15, dy - 15, 30, 24)
		draw_rect(drect, drives[i][2])
		draw_rect(drect, Color(0.4, 0.4, 0.38), false, 1.0)
		# Drive letter
		_draw_centered_text(drives[i][0], Vector2(dx, dy - 2), 12, Color(0.0, 0.0, 0.0))
		# Label
		_draw_centered_text(drives[i][1], Vector2(dx, dy + 20), 9, Color(0.3, 0.3, 0.3))
		# Highlight C: drive
		if drives[i][3]:
			draw_rect(Rect2(dx - 20, dy - 20, 40, 50), Color(0.2, 0.4, 0.8, 0.15))


func _draw_right_click(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "My Computer")

	# C: drive with right-click menu
	var dx: float = body.position.x + 30
	var dy: float = body.position.y + 40
	var drect := Rect2(dx - 15, dy - 15, 30, 24)
	draw_rect(drect, Color(0.2, 0.4, 0.8, 0.3))
	draw_rect(drect, Color(0.4, 0.4, 0.38), false, 1.0)
	_draw_centered_text("C:", Vector2(dx, dy - 2), 12, Color(1.0, 1.0, 1.0))

	# Context menu
	var menu_x := dx + 20
	var menu_y := dy + 10
	var menu_items := ["Open", "Explore", "Search...", "---", "Format...", "---", "Properties"]
	draw_rect(Rect2(menu_x, menu_y, 100, float(menu_items.size()) * 18 + 6), Color(1.0, 1.0, 1.0))
	draw_rect(Rect2(menu_x, menu_y, 100, float(menu_items.size()) * 18 + 6), Color(0.5, 0.5, 0.5), false, 1.0)
	for i in range(menu_items.size()):
		var iy := menu_y + 3 + float(i) * 18
		if menu_items[i] == "---":
			draw_line(Vector2(menu_x + 4, iy + 9), Vector2(menu_x + 96, iy + 9), Color(0.7, 0.7, 0.7), 1.0)
		elif menu_items[i] == "Properties":
			# Highlighted
			draw_rect(Rect2(menu_x + 2, iy, 96, 18), Color(0.2, 0.4, 0.8))
			_draw_text(menu_items[i], Vector2(menu_x + 8, iy + 14), 11, Color(1.0, 1.0, 1.0))
		else:
			_draw_text(menu_items[i], Vector2(menu_x + 8, iy + 14), 11, Color(0.0, 0.0, 0.0))


func _draw_properties(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(20, 5, w - 40, h - 10), "Local Disk (C:) Properties")

	# Pie chart for disk usage
	var cx := body.position.x + body.size.x / 2.0
	var cy := body.position.y + 60
	var r := 35.0

	# Draw pie: ~70% used (blue), ~30% free (pink)
	var segments := 32
	# Used portion (blue)
	for i in range(int(segments * 0.7)):
		var t := float(i) / segments
		var nt := float(i + 1) / segments
		var a1 := t * TAU - PI / 2.0
		var a2 := nt * TAU - PI / 2.0
		var pts := PackedVector2Array([
			Vector2(cx, cy),
			Vector2(cx + cos(a1) * r, cy + sin(a1) * r),
			Vector2(cx + cos(a2) * r, cy + sin(a2) * r),
		])
		draw_polygon(pts, PackedColorArray([Color(0.15, 0.35, 0.85), Color(0.15, 0.35, 0.85), Color(0.15, 0.35, 0.85)]))
	# Free portion (pink/magenta)
	for i in range(int(segments * 0.7), segments):
		var t := float(i) / segments
		var nt := float(i + 1) / segments
		var a1 := t * TAU - PI / 2.0
		var a2 := nt * TAU - PI / 2.0
		var pts := PackedVector2Array([
			Vector2(cx, cy),
			Vector2(cx + cos(a1) * r, cy + sin(a1) * r),
			Vector2(cx + cos(a2) * r, cy + sin(a2) * r),
		])
		draw_polygon(pts, PackedColorArray([Color(0.85, 0.15, 0.55), Color(0.85, 0.15, 0.55), Color(0.85, 0.15, 0.55)]))

	draw_circle(Vector2(cx, cy), r, Color(0.3, 0.3, 0.3), false, 1.0)

	# Labels
	_draw_text("Used: 28.5 GB", Vector2(body.position.x + 10, body.position.y + 115), 10, Color(0.0, 0.0, 0.0))
	_draw_text("Free: 11.2 GB", Vector2(body.position.x + 10, body.position.y + 130), 10, Color(0.0, 0.0, 0.0))

	# Legend
	draw_rect(Rect2(body.position.x + 10, body.position.y + 140, 10, 10), Color(0.15, 0.35, 0.85))
	_draw_text("Used space", Vector2(body.position.x + 24, body.position.y + 149), 9, Color(0.0, 0.0, 0.0))
	draw_rect(Rect2(body.position.x + 120, body.position.y + 140, 10, 10), Color(0.85, 0.15, 0.55))
	_draw_text("Free space", Vector2(body.position.x + 134, body.position.y + 149), 9, Color(0.0, 0.0, 0.0))


func _draw_tools_tab(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(20, 5, w - 40, h - 10), "Local Disk (C:) Properties")

	# Tab bar
	var tabs := ["General", "Tools", "Hardware", "Sharing"]
	for i in range(tabs.size()):
		var tx: float = body.position.x + 5 + float(i) * 65
		var ty := body.position.y + 2
		var is_selected: bool = (tabs[i] == "Tools")
		if is_selected:
			draw_rect(Rect2(tx, ty, 60, 18), Color(0.93, 0.92, 0.87))
			draw_rect(Rect2(tx, ty, 60, 18), Color(0.5, 0.5, 0.5), false, 1.0)
			draw_rect(Rect2(tx + 1, ty + 17, 58, 2), Color(0.93, 0.92, 0.87))  # Cover bottom
		else:
			draw_rect(Rect2(tx, ty + 2, 60, 16), Color(0.85, 0.84, 0.80))
			draw_rect(Rect2(tx, ty + 2, 60, 16), Color(0.6, 0.6, 0.58), false, 1.0)
		_draw_centered_text(tabs[i], Vector2(tx + 30, ty + 10), 10, Color(0.0, 0.0, 0.0))

	# Tools content
	var cy := body.position.y + 35
	_draw_text("Error-checking", Vector2(body.position.x + 10, cy), 11, Color(0.0, 0.0, 0.0))
	_draw_xp_button(Rect2(body.position.x + 15, cy + 8, 90, 22), "Check Now...")

	cy += 50
	_draw_text("Defragmentation", Vector2(body.position.x + 10, cy), 11, Color(0.0, 0.0, 0.0))
	# Highlighted defrag button
	_draw_xp_button(Rect2(body.position.x + 15, cy + 8, 110, 22), "Defragment Now...")

	cy += 50
	_draw_text("Backup", Vector2(body.position.x + 10, cy), 11, Color(0.0, 0.0, 0.0))
	_draw_xp_button(Rect2(body.position.x + 15, cy + 8, 100, 22), "Backup Now...")


func _draw_analyzing(w: float, h: float) -> void:
	_draw_defrag_view(w, h, "Analyzing...", false)


func _draw_defrag_button(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "Disk Defragmenter")

	# Analysis complete strip
	_draw_text("Analysis display:", Vector2(body.position.x + 5, body.position.y + 16), 10, Color(0.0, 0.0, 0.0))
	_draw_block_strip(Rect2(body.position.x + 5, body.position.y + 22, body.size.x - 10, 20), true)

	# Status
	_draw_text("Analysis complete: This volume is 35% fragmented", Vector2(body.position.x + 5, body.position.y + 56), 9, Color(0.0, 0.0, 0.0))

	# Buttons
	_draw_xp_button(Rect2(body.position.x + 10, body.position.y + 72, 80, 22), "Analyze")
	_draw_xp_button(Rect2(body.position.x + 100, body.position.y + 72, 100, 22), "Defragment", true)

	# Legend
	var ly := body.position.y + 105
	_draw_legend(body.position.x + 5, ly)


func _draw_defragmenting(w: float, h: float) -> void:
	_draw_defrag_view(w, h, "Defragmenting...", true)


func _draw_complete(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "Disk Defragmenter")

	# Fully defragmented view - all blue, then free
	_draw_text("Defragmentation display:", Vector2(body.position.x + 5, body.position.y + 16), 10, Color(0.0, 0.0, 0.0))

	var strip := Rect2(body.position.x + 5, body.position.y + 22, body.size.x - 10, 30)
	_draw_sunken_panel(strip)
	var bw := (strip.size.x - 4) / GRID_COLS
	var bh := (strip.size.y - 4) / 2.0
	for row in range(2):
		for col in range(GRID_COLS):
			var bx := strip.position.x + 2 + float(col) * bw
			var by := strip.position.y + 2 + float(row) * bh
			var idx := row * GRID_COLS + col
			var col_color: Color
			if idx < 10:
				col_color = COL_SYSTEM
			elif idx < int(TOTAL_BLOCKS * 0.7):
				col_color = COL_USED
			else:
				col_color = COL_FREE
			draw_rect(Rect2(bx, by, bw - 1, bh - 1), col_color)

	# Status
	_draw_text("Defragmentation is complete.", Vector2(body.position.x + 5, body.position.y + 66), 10, Color(0.0, 0.55, 0.0))
	_draw_text("0% fragmented", Vector2(body.position.x + 5, body.position.y + 80), 10, Color(0.0, 0.0, 0.0))

	# Green checkmark
	var cx := body.position.x + body.size.x / 2.0
	var cy := body.position.y + 115
	draw_circle(Vector2(cx, cy), 18, Color(0.2, 0.7, 0.2, 0.2))
	# Checkmark lines
	draw_line(Vector2(cx - 10, cy), Vector2(cx - 3, cy + 8), Color(0.15, 0.65, 0.15), 3.0)
	draw_line(Vector2(cx - 3, cy + 8), Vector2(cx + 12, cy - 8), Color(0.15, 0.65, 0.15), 3.0)

	_draw_xp_button(Rect2(body.position.x + body.size.x - 70, body.position.y + body.size.y - 30, 60, 22), "Close", true)


func _draw_defrag_view(w: float, h: float, status: String, is_defrag: bool) -> void:
	var body := _draw_mini_window(Rect2(10, 5, w - 20, h - 10), "Disk Defragmenter")

	# Top label
	if is_defrag:
		_draw_text("Defragmentation display:", Vector2(body.position.x + 5, body.position.y + 16), 10, Color(0.0, 0.0, 0.0))
	else:
		_draw_text("Analysis display:", Vector2(body.position.x + 5, body.position.y + 16), 10, Color(0.0, 0.0, 0.0))

	# Block grid
	var grid_rect := Rect2(body.position.x + 5, body.position.y + 22, body.size.x - 10, 80)
	_draw_sunken_panel(grid_rect)
	_draw_block_grid(grid_rect, is_defrag)

	# Progress bar
	var bar_y := body.position.y + 110
	_draw_text(status, Vector2(body.position.x + 5, bar_y), 10, Color(0.0, 0.0, 0.0))
	var pct := _wait_progress * 100.0
	_draw_text("%d%%" % int(pct), Vector2(body.end.x - 45, bar_y), 10, Color(0.0, 0.0, 0.0))
	_draw_progress_bar(Rect2(body.position.x + 5, bar_y + 5, body.size.x - 10, 14), _wait_progress)

	# Legend
	_draw_legend(body.position.x + 5, bar_y + 28)


func _draw_block_grid(rect: Rect2, is_defrag: bool) -> void:
	var bw := (rect.size.x - 4) / GRID_COLS
	var bh := (rect.size.y - 4) / GRID_ROWS

	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			var idx := row * GRID_COLS + col
			var bx := rect.position.x + 2 + float(col) * bw
			var by := rect.position.y + 2 + float(row) * bh

			var block_type: int = _blocks[idx] if idx < _blocks.size() else 0
			var col_color: Color

			if is_defrag and _wait_progress > 0.0:
				# During defrag, progressively convert fragmented blocks
				var progress_idx := int(_wait_progress * TOTAL_BLOCKS)
				if idx < progress_idx:
					# Already defragged
					if block_type == 2:
						col_color = COL_MOVED  # Was fragmented, now moved
					elif block_type == 3:
						col_color = COL_SYSTEM
					elif block_type == 0:
						col_color = COL_FREE
					else:
						col_color = COL_USED
				else:
					col_color = _block_color(block_type)
			else:
				col_color = _block_color(block_type)

			draw_rect(Rect2(bx, by, bw - 1, bh - 1), col_color)


func _draw_block_strip(rect: Rect2, _show_fragmented: bool) -> void:
	_draw_sunken_panel(rect)
	var bw := (rect.size.x - 4) / GRID_COLS
	for col in range(GRID_COLS):
		var bx := rect.position.x + 2 + float(col) * bw
		var idx := col
		var block_type: int = _blocks[idx] if idx < _blocks.size() else 0
		draw_rect(Rect2(bx, rect.position.y + 2, bw - 1, rect.size.y - 4), _block_color(block_type))


func _draw_legend(x: float, y: float) -> void:
	var items := [
		[COL_USED, "Contiguous"],
		[COL_FRAG, "Fragmented"],
		[COL_SYSTEM, "System"],
		[COL_FREE, "Free"],
	]
	for i in range(items.size()):
		var ix: float = x + float(i) * 80
		draw_rect(Rect2(ix, y, 10, 10), items[i][0])
		draw_rect(Rect2(ix, y, 10, 10), Color(0.4, 0.4, 0.4), false, 1.0)
		_draw_text(items[i][1], Vector2(ix + 14, y + 9), 8, Color(0.0, 0.0, 0.0))


func _block_color(block_type: int) -> Color:
	match block_type:
		0: return COL_FREE
		1: return COL_USED
		2: return COL_FRAG
		3: return COL_SYSTEM
		_: return COL_FREE
