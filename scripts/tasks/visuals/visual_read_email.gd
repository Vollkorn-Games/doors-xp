extends "res://scripts/tasks/task_visual.gd"

## Read Email visual: Outlook Express-style email client.
## Steps: Open Inbox → Read Message → Scroll Down → Compose Reply → Send Reply


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return

	draw_rect(Rect2(0, 0, w, h), Color(0.93, 0.92, 0.87))

	match _step_index:
		0: _draw_open_inbox(w, h)
		1: _draw_read_message(w, h)
		2: _draw_scroll_down(w, h)
		3: _draw_compose_reply(w, h)
		4: _draw_send_reply(w, h)
		_: _draw_open_inbox(w, h)


func _draw_open_inbox(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(8, 3, w - 16, h - 6), "Outlook Express")

	# Toolbar buttons
	var toolbar_y := body.position.y + 2
	var tools := ["New Mail", "Reply", "Forward", "Send"]
	for i in range(tools.size()):
		var tx: float = body.position.x + 4 + float(i) * 65
		_draw_xp_button(Rect2(tx, toolbar_y, 60, 18), tools[i])

	# Split view: folder tree (left) | message list (right)
	var split_y := toolbar_y + 24
	var tree_w := 80.0
	var tree_rect := Rect2(body.position.x + 4, split_y, tree_w, body.size.y - 30)
	_draw_sunken_panel(tree_rect)

	# Folder tree
	var folders := [
		[0, "Local Folders"],
		[1, "Inbox (1)"],
		[1, "Outbox"],
		[1, "Sent Items"],
		[1, "Deleted Items"],
		[1, "Drafts"],
	]
	for i in range(folders.size()):
		var fy := tree_rect.position.y + 4 + float(i) * 15
		var indent: float = float(folders[i][0]) * 12
		var fname: String = folders[i][1]
		var is_inbox := fname.begins_with("Inbox")
		if is_inbox:
			# Bold inbox
			_draw_text(fname, Vector2(tree_rect.position.x + 4 + indent, fy + 11), 9, Color(0.0, 0.0, 0.0))
			# Tiny folder icon
			draw_rect(Rect2(tree_rect.position.x + indent - 2, fy + 2, 8, 7), Color(0.82, 0.68, 0.22))
		else:
			_draw_text(fname, Vector2(tree_rect.position.x + 4 + indent, fy + 11), 8, Color(0.3, 0.3, 0.3))

	# Message list (right panel)
	var msg_rect := Rect2(body.position.x + tree_w + 8, split_y, body.size.x - tree_w - 12, body.size.y - 30)
	_draw_sunken_panel(msg_rect)

	# Column headers
	var hdr_y := msg_rect.position.y + 2
	draw_rect(Rect2(msg_rect.position.x + 1, hdr_y, msg_rect.size.x - 2, 14), Color(0.88, 0.87, 0.84))
	_draw_text("From", Vector2(msg_rect.position.x + 4, hdr_y + 11), 8, Color(0.3, 0.3, 0.3))
	_draw_text("Subject", Vector2(msg_rect.position.x + 80, hdr_y + 11), 8, Color(0.3, 0.3, 0.3))

	# Unread message
	var my := hdr_y + 16
	draw_rect(Rect2(msg_rect.position.x + 1, my, msg_rect.size.x - 2, 16), Color(1.0, 1.0, 1.0))
	# Envelope icon
	draw_rect(Rect2(msg_rect.position.x + 4, my + 3, 10, 8), Color(0.95, 0.90, 0.55))
	draw_rect(Rect2(msg_rect.position.x + 4, my + 3, 10, 8), Color(0.7, 0.6, 0.3), false, 1.0)
	_draw_text("boss@co...", Vector2(msg_rect.position.x + 18, my + 13), 8, Color(0.0, 0.0, 0.0))
	_draw_text("Q3 Budget Review", Vector2(msg_rect.position.x + 80, my + 13), 8, Color(0.0, 0.0, 0.0))


func _draw_read_message(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(8, 3, w - 16, h - 6), "Outlook Express")

	# Toolbar
	var toolbar_y := body.position.y + 2
	var tools := ["New Mail", "Reply", "Forward", "Send"]
	for i in range(tools.size()):
		var tx: float = body.position.x + 4 + float(i) * 65
		_draw_xp_button(Rect2(tx, toolbar_y, 60, 18), tools[i])

	# Message list at top with highlighted email
	var list_y := toolbar_y + 24
	var list_rect := Rect2(body.position.x + 4, list_y, body.size.x - 8, 40)
	_draw_sunken_panel(list_rect)

	# Header
	draw_rect(Rect2(list_rect.position.x + 1, list_rect.position.y + 1, list_rect.size.x - 2, 14), Color(0.88, 0.87, 0.84))
	_draw_text("From", Vector2(list_rect.position.x + 4, list_rect.position.y + 12), 8, Color(0.3, 0.3, 0.3))
	_draw_text("Subject", Vector2(list_rect.position.x + 100, list_rect.position.y + 12), 8, Color(0.3, 0.3, 0.3))

	# Selected message (highlighted)
	var my := list_rect.position.y + 16
	draw_rect(Rect2(list_rect.position.x + 1, my, list_rect.size.x - 2, 16), Color(0.2, 0.4, 0.8))
	_draw_text("boss@company.com", Vector2(list_rect.position.x + 4, my + 13), 8, Color(1.0, 1.0, 1.0))
	_draw_text("Q3 Budget Review", Vector2(list_rect.position.x + 100, my + 13), 8, Color(1.0, 1.0, 1.0))

	# Preview pane below
	var preview_rect := Rect2(body.position.x + 4, list_y + 46, body.size.x - 8, body.size.y - 52)
	_draw_sunken_panel(preview_rect)
	_draw_text("From: boss@company.com", Vector2(preview_rect.position.x + 4, preview_rect.position.y + 14), 9, Color(0.3, 0.3, 0.3))
	_draw_text("Subject: Q3 Budget Review", Vector2(preview_rect.position.x + 4, preview_rect.position.y + 28), 9, Color(0.3, 0.3, 0.3))
	draw_line(Vector2(preview_rect.position.x + 4, preview_rect.position.y + 34), Vector2(preview_rect.end.x - 4, preview_rect.position.y + 34), Color(0.7, 0.7, 0.7), 1.0)


func _draw_scroll_down(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(8, 3, w - 16, h - 6), "Q3 Budget Review")

	# Email body
	var content_rect := Rect2(body.position.x + 4, body.position.y + 4, body.size.x - 20, body.size.y - 8)
	_draw_sunken_panel(content_rect)

	var lines := [
		"Hi,",
		"",
		"Please review the attached Q3",
		"budget report and provide your",
		"feedback by end of day Friday.",
		"",
		"Key items to review:",
		"- Marketing spend (pg 3)",
		"- IT infrastructure (pg 5)",
		"- Travel expenses (pg 7)",
		"",
		"Thanks,",
		"The Boss",
	]
	for i in range(lines.size()):
		var ly := content_rect.position.y + 14 + float(i) * 13
		if ly < content_rect.end.y - 4:
			_draw_text(lines[i], Vector2(content_rect.position.x + 6, ly), 9, Color(0.0, 0.0, 0.0))

	# Scrollbar
	var sb_x := content_rect.end.x + 2
	draw_rect(Rect2(sb_x, content_rect.position.y, 12, content_rect.size.y), Color(0.85, 0.85, 0.85))
	# Scroll thumb (moving down)
	var thumb_y := content_rect.position.y + content_rect.size.y * 0.5
	draw_rect(Rect2(sb_x + 1, thumb_y, 10, 25), Color(0.65, 0.65, 0.62))
	draw_rect(Rect2(sb_x + 1, thumb_y, 10, 25), Color(0.5, 0.5, 0.48), false, 1.0)
	# Arrow indicator
	_draw_centered_text("v", Vector2(sb_x + 6, content_rect.end.y - 6), 10, Color(0.3, 0.3, 0.3))


func _draw_compose_reply(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(8, 3, w - 16, h - 6), "RE: Q3 Budget Review")

	# To/Subject fields
	var fy := body.position.y + 6
	_draw_text("To:", Vector2(body.position.x + 6, fy + 11), 9, Color(0.3, 0.3, 0.3))
	_draw_sunken_panel(Rect2(body.position.x + 50, fy, body.size.x - 56, 16))
	_draw_text("boss@company.com", Vector2(body.position.x + 54, fy + 12), 9, Color(0.0, 0.0, 0.0))

	fy += 22
	_draw_text("Subject:", Vector2(body.position.x + 6, fy + 11), 9, Color(0.3, 0.3, 0.3))
	_draw_sunken_panel(Rect2(body.position.x + 50, fy, body.size.x - 56, 16))
	_draw_text("RE: Q3 Budget Review", Vector2(body.position.x + 54, fy + 12), 9, Color(0.0, 0.0, 0.0))

	# Body area
	var body_rect := Rect2(body.position.x + 4, fy + 22, body.size.x - 8, body.size.y - 56)
	_draw_sunken_panel(body_rect)

	_draw_text("Hi Boss,", Vector2(body_rect.position.x + 6, body_rect.position.y + 14), 9, Color(0.0, 0.0, 0.0))
	_draw_text("Reviewed the report. Looks good!", Vector2(body_rect.position.x + 6, body_rect.position.y + 28), 9, Color(0.0, 0.0, 0.0))
	_draw_text("I have a few notes on pg 5.|", Vector2(body_rect.position.x + 6, body_rect.position.y + 42), 9, Color(0.0, 0.0, 0.0))

	# Blinking cursor indicator
	draw_line(Vector2(body_rect.position.x + 140, body_rect.position.y + 34), Vector2(body_rect.position.x + 140, body_rect.position.y + 44), Color(0.0, 0.0, 0.0), 1.0)


func _draw_send_reply(w: float, h: float) -> void:
	var body := _draw_mini_window(Rect2(8, 3, w - 16, h - 6), "RE: Q3 Budget Review")

	# Send button highlighted at top
	_draw_xp_button(Rect2(body.position.x + 4, body.position.y + 4, 60, 20), "Send", true)
	_draw_xp_button(Rect2(body.position.x + 70, body.position.y + 4, 60, 20), "Attach")

	# Flying envelope animation
	var cx := w / 2.0
	var cy := h * 0.55

	# Envelope
	var env_w := 40.0
	var env_h := 28.0
	draw_rect(Rect2(cx - env_w / 2, cy - env_h / 2, env_w, env_h), Color(0.95, 0.92, 0.82))
	draw_rect(Rect2(cx - env_w / 2, cy - env_h / 2, env_w, env_h), Color(0.6, 0.55, 0.4), false, 1.0)
	# Envelope flap
	draw_line(Vector2(cx - env_w / 2, cy - env_h / 2), Vector2(cx, cy), Color(0.6, 0.55, 0.4), 1.0)
	draw_line(Vector2(cx + env_w / 2, cy - env_h / 2), Vector2(cx, cy), Color(0.6, 0.55, 0.4), 1.0)

	# Motion lines
	for i in range(3):
		var lx := cx - env_w / 2 - 8 - float(i) * 8
		var ly := cy - 4 + float(i) * 4
		draw_line(Vector2(lx, ly), Vector2(lx - 12, ly), Color(0.5, 0.5, 0.5, 0.4 - float(i) * 0.1), 1.5)

	_draw_centered_text("Sending...", Vector2(cx, cy + env_h / 2 + 16), 11, Color(0.3, 0.3, 0.3))
