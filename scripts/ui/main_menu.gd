extends Control

## Main menu styled as the authentic Windows XP login screen.
## Split layout: left side = logo + welcome text, right side = user account.
## Dark top/bottom bars, blue gradient background, vertical divider.

const _XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")

@onready var _start_button: Button = %StartButton
@onready var _quit_button: Button = %QuitButton
@onready var _background: ColorRect = %Background

# XP login color palette
const BG_DARK := Color(0.04, 0.15, 0.45)
const BG_MID := Color(0.12, 0.35, 0.72)
const BG_LIGHT := Color(0.28, 0.50, 0.82)
const BAR_COLOR := Color(0.02, 0.08, 0.32)
const BAR_BORDER := Color(0.15, 0.35, 0.70)
const DIVIDER_COLOR := Color(0.30, 0.50, 0.80, 0.5)
const USER_HIGHLIGHT := Color(0.10, 0.28, 0.60)
const USER_BORDER := Color(0.45, 0.60, 0.90)


func _ready() -> void:
	theme = _XPTheme.build_theme()
	_build_login_screen()
	_start_button.pressed.connect(_on_start)
	_quit_button.pressed.connect(_on_quit)


func _build_login_screen() -> void:
	_background.color = BG_MID

	# Add gradient overlay for the background
	var bg_overlay := Control.new()
	bg_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_overlay.draw.connect(_draw_bg_gradient.bind(bg_overlay))
	add_child(bg_overlay)

	# --- Top dark bar ---
	var top_bar := _make_bar()
	top_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 50.0
	add_child(top_bar)

	# --- Bottom dark bar ---
	var bottom_bar := _make_bar()
	bottom_bar.anchor_top = 1.0
	bottom_bar.anchor_bottom = 1.0
	bottom_bar.anchor_left = 0.0
	bottom_bar.anchor_right = 1.0
	bottom_bar.offset_top = -52.0
	bottom_bar.offset_bottom = 0.0
	add_child(bottom_bar)

	# Bottom bar content
	var bottom_hbox := HBoxContainer.new()
	bottom_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bottom_hbox.add_theme_constant_override("separation", 12)
	bottom_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	bottom_bar.add_child(bottom_hbox)

	# Spacer for left margin
	var bottom_spacer := Control.new()
	bottom_spacer.custom_minimum_size.x = 16.0
	bottom_hbox.add_child(bottom_spacer)

	# Turn off button (styled as XP shutdown button)
	var turn_off_btn := Button.new()
	turn_off_btn.text = "Turn off computer"
	turn_off_btn.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	turn_off_btn.add_theme_color_override("font_hover_color", _XPTheme.TEXT_WHITE)
	turn_off_btn.add_theme_font_size_override("font_size", 12)
	var shutdown_style := StyleBoxFlat.new()
	shutdown_style.bg_color = Color(0.72, 0.20, 0.12)
	shutdown_style.set_corner_radius_all(4)
	shutdown_style.set_border_width_all(1)
	shutdown_style.border_color = Color(0.85, 0.35, 0.25)
	shutdown_style.content_margin_left = 12.0
	shutdown_style.content_margin_right = 12.0
	shutdown_style.content_margin_top = 6.0
	shutdown_style.content_margin_bottom = 6.0
	turn_off_btn.add_theme_stylebox_override("normal", shutdown_style)
	var shutdown_hover := shutdown_style.duplicate()
	shutdown_hover.bg_color = Color(0.82, 0.28, 0.18)
	turn_off_btn.add_theme_stylebox_override("hover", shutdown_hover)
	turn_off_btn.add_theme_stylebox_override("pressed", shutdown_style)
	turn_off_btn.pressed.connect(_on_quit)
	bottom_hbox.add_child(turn_off_btn)

	# --- Main content area (between bars) ---
	var content := HBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_top = 50.0
	content.offset_bottom = -52.0
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)

	# Left half — logo and welcome text
	var left_panel := VBoxContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(left_panel)

	# Spacer to push content down to center-ish
	var left_top_space := Control.new()
	left_top_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_top_space.custom_minimum_size.y = 40.0
	left_panel.add_child(left_top_space)

	# Windows flag icon (colored blocks arranged like the XP logo)
	var flag_container := HBoxContainer.new()
	flag_container.alignment = BoxContainer.ALIGNMENT_CENTER
	flag_container.add_theme_constant_override("separation", 3)
	left_panel.add_child(flag_container)

	# 2x2 grid of colored blocks
	var flag_grid := GridContainer.new()
	flag_grid.columns = 2
	flag_grid.add_theme_constant_override("h_separation", 3)
	flag_grid.add_theme_constant_override("v_separation", 3)
	flag_container.add_child(flag_grid)

	var flag_colors := [
		Color(0.90, 0.20, 0.15),  # Red (top-left)
		Color(0.20, 0.70, 0.20),  # Green (top-right)
		Color(0.15, 0.40, 0.85),  # Blue (bottom-left)
		Color(0.95, 0.75, 0.10),  # Yellow (bottom-right)
	]
	for fc: Color in flag_colors:
		var block := PanelContainer.new()
		var block_style := StyleBoxFlat.new()
		block_style.bg_color = fc
		block_style.set_corner_radius_all(2)
		block_style.content_margin_left = 14.0
		block_style.content_margin_right = 14.0
		block_style.content_margin_top = 12.0
		block_style.content_margin_bottom = 12.0
		block.add_theme_stylebox_override("panel", block_style)
		flag_grid.add_child(block)

	# "Doors XP" title
	var title := Label.new()
	title.text = "Doors XP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.3))
	left_panel.add_child(title)

	# Subtitle
	var subtitle := Label.new()
	subtitle.text = "Professional Edition"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.8, 0.95))
	subtitle.add_theme_font_size_override("font_size", 12)
	left_panel.add_child(subtitle)

	# Spacer
	var mid_space := Control.new()
	mid_space.custom_minimum_size.y = 30.0
	left_panel.add_child(mid_space)

	# "To begin, click your user name"
	var welcome_text := Label.new()
	welcome_text.text = "To begin, click your user name"
	welcome_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	welcome_text.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	welcome_text.add_theme_font_size_override("font_size", 14)
	left_panel.add_child(welcome_text)

	var left_bottom_space := Control.new()
	left_bottom_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_panel.add_child(left_bottom_space)

	# --- Vertical divider ---
	var divider := ColorRect.new()
	divider.custom_minimum_size.x = 1.0
	divider.color = DIVIDER_COLOR
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(divider)

	# --- Right half — user account ---
	var right_panel := VBoxContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	right_panel.add_theme_constant_override("separation", 20)
	right_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(right_panel)

	var right_top_space := Control.new()
	right_top_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_child(right_top_space)

	# User account entry (clickable)
	var user_entry := _make_user_entry("Player", ":-)", true)
	right_panel.add_child(user_entry)

	var right_bottom_space := Control.new()
	right_bottom_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_child(right_bottom_space)

	# --- Version label ---
	var version := Label.new()
	version.text = "Doors XP v0.1"
	version.add_theme_color_override("font_color", Color(0.5, 0.6, 0.8, 0.6))
	version.add_theme_font_size_override("font_size", 10)
	version.anchor_top = 1.0
	version.anchor_bottom = 1.0
	version.offset_left = 8.0
	version.offset_top = -20.0
	version.offset_right = 150.0
	add_child(version)


func _make_bar() -> PanelContainer:
	var bar := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = BAR_COLOR
	style.border_color = BAR_BORDER
	style.border_width_top = 0
	style.border_width_bottom = 2
	style.border_width_left = 0
	style.border_width_right = 0
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	bar.add_theme_stylebox_override("panel", style)
	return bar


func _make_user_entry(username: String, icon_text: String, active: bool) -> PanelContainer:
	var entry := PanelContainer.new()
	var entry_style := StyleBoxFlat.new()
	if active:
		entry_style.bg_color = Color(USER_HIGHLIGHT, 0.5)
		entry_style.border_color = USER_BORDER
		entry_style.set_border_width_all(2)
	else:
		entry_style.bg_color = Color(0, 0, 0, 0)
		entry_style.set_border_width_all(0)
	entry_style.set_corner_radius_all(4)
	entry_style.content_margin_left = 12.0
	entry_style.content_margin_right = 20.0
	entry_style.content_margin_top = 10.0
	entry_style.content_margin_bottom = 10.0
	entry.add_theme_stylebox_override("panel", entry_style)
	entry.custom_minimum_size.x = 280.0

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	entry.add_child(hbox)

	# User avatar
	var avatar := PanelContainer.new()
	var avatar_style := StyleBoxFlat.new()
	avatar_style.bg_color = Color(0.82, 0.85, 0.90)
	avatar_style.border_color = Color(0.45, 0.55, 0.75)
	avatar_style.set_border_width_all(2)
	avatar_style.set_corner_radius_all(4)
	avatar_style.content_margin_left = 12.0
	avatar_style.content_margin_right = 12.0
	avatar_style.content_margin_top = 10.0
	avatar_style.content_margin_bottom = 10.0
	avatar.add_theme_stylebox_override("panel", avatar_style)
	hbox.add_child(avatar)

	var avatar_label := Label.new()
	avatar_label.text = icon_text
	avatar_label.add_theme_font_size_override("font_size", 28)
	avatar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_child(avatar_label)

	# Username + "Log In" button (vertical stack)
	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 8)
	info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(info_vbox)

	var name_label := Label.new()
	name_label.text = username
	name_label.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_constant_override("outline_size", 2)
	name_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.25))
	info_vbox.add_child(name_label)

	# Log In button styled as XP arrow button
	var login_btn := Button.new()
	login_btn.text = "Log In  >"
	login_btn.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	login_btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.8))
	login_btn.add_theme_font_size_override("font_size", 12)
	var login_style := StyleBoxFlat.new()
	login_style.bg_color = Color(0.12, 0.35, 0.70)
	login_style.border_color = Color(0.30, 0.55, 0.90)
	login_style.set_border_width_all(1)
	login_style.set_corner_radius_all(3)
	login_style.content_margin_left = 10.0
	login_style.content_margin_right = 10.0
	login_style.content_margin_top = 4.0
	login_style.content_margin_bottom = 4.0
	login_btn.add_theme_stylebox_override("normal", login_style)
	var login_hover := login_style.duplicate()
	login_hover.bg_color = Color(0.18, 0.42, 0.80)
	login_btn.add_theme_stylebox_override("hover", login_hover)
	login_btn.add_theme_stylebox_override("pressed", login_style)
	var login_focus := login_style.duplicate()
	login_focus.border_color = Color(0.50, 0.70, 1.0)
	login_focus.set_border_width_all(2)
	login_btn.add_theme_stylebox_override("focus", login_focus)
	login_btn.add_theme_color_override("font_focus_color", _XPTheme.TEXT_WHITE)
	login_btn.add_theme_color_override("font_pressed_color", _XPTheme.TEXT_WHITE)
	login_btn.pressed.connect(_on_start)
	login_btn.focus_mode = Control.FOCUS_ALL
	login_btn.grab_focus.call_deferred()
	info_vbox.add_child(login_btn)

	return entry


func _draw_bg_gradient(overlay: Control) -> void:
	var w := overlay.size.x
	var h := overlay.size.y
	if w <= 0 or h <= 0:
		return

	# Radial-ish gradient: lighter in center-left, darker at edges
	# Approximated with horizontal + vertical gradient bands
	var bands := 40
	for i in range(bands):
		var t := float(i) / bands
		var next_t := float(i + 1) / bands
		# Vertical gradient: darker at top and bottom, lighter in middle
		var center_dist: float = absf(t - 0.45) * 2.0  # 0 at center, 1 at edges
		var brightness := 1.0 - center_dist * center_dist * 0.4
		var color := BG_MID.lerp(BG_LIGHT, brightness * 0.5)
		# Darken top more
		if t < 0.15:
			color = color.lerp(BG_DARK, (0.15 - t) / 0.15 * 0.6)
		# Darken bottom
		if t > 0.85:
			color = color.lerp(BG_DARK, (t - 0.85) / 0.15 * 0.5)
		var y := t * h
		var band_h := (next_t - t) * h + 1.0
		overlay.draw_rect(Rect2(0, y, w, band_h), color)

	# Subtle radial glow on the left side (approximated with circles)
	var glow_center := Vector2(w * 0.35, h * 0.45)
	var glow_color := Color(0.45, 0.60, 0.88, 0.08)
	for r in range(8, 0, -1):
		var radius: float = r * 40.0
		overlay.draw_circle(glow_center, radius, glow_color)


func _on_start() -> void:
	GameManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/desktop.tscn")


func _on_quit() -> void:
	get_tree().quit()
