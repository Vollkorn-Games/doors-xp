class_name XPThemeBuilder
extends RefCounted

## Builds a Godot Theme that replicates the Windows XP visual style.

# Windows XP Color Palette
const TITLE_BAR_BLUE := Color(0.0, 0.34, 0.84)
const TITLE_BAR_GRADIENT_END := Color(0.15, 0.55, 0.96)
const TITLE_BAR_INACTIVE := Color(0.49, 0.55, 0.67)
const BUTTON_FACE := Color(0.93, 0.92, 0.87)
const BUTTON_HOVER := Color(0.88, 0.92, 0.98)
const BUTTON_PRESSED := Color(0.85, 0.85, 0.82)
const BUTTON_BORDER := Color(0.0, 0.24, 0.55)
const WINDOW_BG := Color(0.93, 0.92, 0.87)
const DESKTOP_BG := Color(0.22, 0.45, 0.73)
const TASKBAR_BG := Color(0.13, 0.38, 0.85)
const START_BUTTON_GREEN := Color(0.21, 0.62, 0.17)
const START_BUTTON_HOVER := Color(0.28, 0.72, 0.24)
const TEXT_COLOR := Color(0.0, 0.0, 0.0)
const TEXT_WHITE := Color(1.0, 1.0, 1.0)
const PROGRESS_GREEN := Color(0.35, 0.68, 0.22)
const PROGRESS_BG := Color(0.85, 0.85, 0.85)
const SELECTION_BLUE := Color(0.2, 0.4, 0.8)
const ERROR_RED := Color(0.8, 0.15, 0.15)
const WARNING_YELLOW := Color(0.9, 0.8, 0.1)
const SUCCESS_GREEN := Color(0.2, 0.7, 0.2)
const SEPARATOR_COLOR := Color(0.7, 0.7, 0.65)


static func build_theme() -> Theme:
	var theme := Theme.new()

	# Default font size
	theme.set_default_font_size(14)

	# --- Button styles ---
	theme.set_stylebox("normal", "Button", _make_button_normal())
	theme.set_stylebox("hover", "Button", _make_button_hover())
	theme.set_stylebox("pressed", "Button", _make_button_pressed())
	theme.set_stylebox("disabled", "Button", _make_button_disabled())
	theme.set_stylebox("focus", "Button", _make_button_focus())
	theme.set_color("font_color", "Button", TEXT_COLOR)
	theme.set_color("font_hover_color", "Button", TEXT_COLOR)
	theme.set_color("font_pressed_color", "Button", TEXT_COLOR)

	# --- Panel styles ---
	theme.set_stylebox("panel", "Panel", _make_panel_style())
	theme.set_stylebox("panel", "PanelContainer", _make_panel_style())

	# --- ProgressBar styles ---
	theme.set_stylebox("background", "ProgressBar", _make_progress_bg())
	theme.set_stylebox("fill", "ProgressBar", _make_progress_fill())

	# --- Label ---
	theme.set_color("font_color", "Label", TEXT_COLOR)
	theme.set_font_size("font_size", "Label", 14)

	# --- HSeparator ---
	theme.set_stylebox("separator", "HSeparator", _make_separator())

	return theme


# --- Button StyleBoxes ---

static func _make_button_normal() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BUTTON_FACE
	s.border_color = BUTTON_BORDER
	s.set_border_width_all(1)
	s.border_width_top = 1
	s.border_width_left = 1
	s.set_corner_radius_all(3)
	s.content_margin_left = 10.0
	s.content_margin_right = 10.0
	s.content_margin_top = 5.0
	s.content_margin_bottom = 5.0
	s.shadow_color = Color(0.0, 0.0, 0.0, 0.15)
	s.shadow_size = 1
	return s


static func _make_button_hover() -> StyleBoxFlat:
	var s := _make_button_normal()
	s.bg_color = BUTTON_HOVER
	s.border_color = Color(0.0, 0.4, 0.8)
	return s


static func _make_button_pressed() -> StyleBoxFlat:
	var s := _make_button_normal()
	s.bg_color = BUTTON_PRESSED
	s.shadow_size = 0
	s.border_color = Color(0.0, 0.2, 0.5)
	return s


static func _make_button_disabled() -> StyleBoxFlat:
	var s := _make_button_normal()
	s.bg_color = Color(0.88, 0.87, 0.84)
	s.border_color = Color(0.6, 0.6, 0.6)
	return s


static func _make_button_focus() -> StyleBoxFlat:
	var s := _make_button_normal()
	s.border_color = Color(0.0, 0.3, 0.7)
	s.set_border_width_all(2)
	return s


# --- Panel StyleBoxes ---

static func _make_panel_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = WINDOW_BG
	s.border_color = Color(0.55, 0.55, 0.5)
	s.set_border_width_all(1)
	s.set_corner_radius_all(0)
	s.content_margin_left = 4.0
	s.content_margin_right = 4.0
	s.content_margin_top = 4.0
	s.content_margin_bottom = 4.0
	return s


# --- ProgressBar StyleBoxes ---

static func _make_progress_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PROGRESS_BG
	s.border_color = Color(0.5, 0.5, 0.5)
	s.set_border_width_all(1)
	s.set_corner_radius_all(0)
	return s


static func _make_progress_fill() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PROGRESS_GREEN
	s.set_corner_radius_all(0)
	return s


# --- Separator ---

static func _make_separator() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = SEPARATOR_COLOR
	s.content_margin_top = 4.0
	s.content_margin_bottom = 4.0
	return s


# --- Reusable custom styles (called directly by scene scripts) ---

static func make_title_bar_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = TITLE_BAR_BLUE
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 0
	s.corner_radius_bottom_right = 0
	# XP gradient hint: lighter border on top to simulate the gradient shine
	s.border_color = TITLE_BAR_GRADIENT_END
	s.border_width_top = 2
	s.border_width_left = 0
	s.border_width_right = 0
	s.border_width_bottom = 0
	s.content_margin_left = 8.0
	s.content_margin_right = 4.0
	s.content_margin_top = 4.0
	s.content_margin_bottom = 4.0
	return s


static func make_title_bar_inactive_style() -> StyleBoxFlat:
	var s := make_title_bar_style()
	s.bg_color = TITLE_BAR_INACTIVE
	return s


static func make_window_body_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = WINDOW_BG
	s.border_color = Color(0.0, 0.34, 0.84, 0.5)
	s.border_width_left = 3
	s.border_width_right = 3
	s.border_width_bottom = 3
	s.border_width_top = 0
	s.corner_radius_bottom_left = 4
	s.corner_radius_bottom_right = 4
	s.content_margin_left = 8.0
	s.content_margin_right = 8.0
	s.content_margin_top = 8.0
	s.content_margin_bottom = 8.0
	return s


static func make_taskbar_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = TASKBAR_BG
	# XP taskbar has a bright highlight line at the top edge
	s.border_color = Color(0.35, 0.6, 1.0)
	s.border_width_top = 2
	s.border_width_bottom = 0
	s.border_width_left = 0
	s.border_width_right = 0
	s.content_margin_left = 4.0
	s.content_margin_right = 4.0
	s.content_margin_top = 3.0
	s.content_margin_bottom = 3.0
	return s


static func make_taskbar_button_normal() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.20, 0.48, 0.90)
	# 3D raised: lighter border + shadow for depth
	s.border_color = Color(0.35, 0.60, 1.0)
	s.set_border_width_all(1)
	s.set_corner_radius_all(2)
	s.content_margin_left = 6.0
	s.content_margin_right = 6.0
	s.content_margin_top = 3.0
	s.content_margin_bottom = 3.0
	s.shadow_color = Color(0.0, 0.0, 0.0, 0.2)
	s.shadow_size = 1
	s.shadow_offset = Vector2(1, 1)
	return s


static func make_taskbar_button_selected() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	# Sunken look: darker bg, dark border, thicker top/left
	s.bg_color = Color(0.16, 0.40, 0.80)
	s.border_color = Color(0.08, 0.22, 0.55)
	s.border_width_top = 2
	s.border_width_left = 2
	s.border_width_bottom = 1
	s.border_width_right = 1
	s.set_corner_radius_all(2)
	s.content_margin_left = 7.0
	s.content_margin_right = 5.0
	s.content_margin_top = 4.0
	s.content_margin_bottom = 2.0
	s.shadow_size = 0
	return s


static func make_taskbar_button_empty() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.15, 0.38, 0.78, 0.15)
	s.border_color = Color(0.1, 0.3, 0.65, 0.15)
	s.set_border_width_all(1)
	s.set_corner_radius_all(2)
	s.content_margin_left = 6.0
	s.content_margin_right = 6.0
	s.content_margin_top = 3.0
	s.content_margin_bottom = 3.0
	return s


static func make_start_button_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = START_BUTTON_GREEN
	# Lighter green top border for gradient hint
	s.border_color = Color(0.28, 0.72, 0.22)
	s.border_width_top = 2
	s.border_width_bottom = 1
	s.border_width_left = 1
	s.border_width_right = 1
	s.corner_radius_top_left = 10
	s.corner_radius_bottom_left = 10
	s.corner_radius_top_right = 2
	s.corner_radius_bottom_right = 2
	s.content_margin_left = 6.0
	s.content_margin_right = 10.0
	s.content_margin_top = 4.0
	s.content_margin_bottom = 4.0
	s.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	s.shadow_size = 2
	return s


static func make_start_button_hover() -> StyleBoxFlat:
	var s := make_start_button_style()
	s.bg_color = START_BUTTON_HOVER
	s.border_color = Color(0.35, 0.80, 0.30)
	return s


static func make_system_tray_style() -> StyleBoxFlat:
	## Sunken notification area / clock region on the right of the taskbar
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.1, 0.32, 0.75)
	s.border_color = Color(0.08, 0.25, 0.6)
	s.set_border_width_all(1)
	s.border_width_right = 0
	s.set_corner_radius_all(2)
	s.content_margin_left = 10.0
	s.content_margin_right = 10.0
	s.content_margin_top = 2.0
	s.content_margin_bottom = 2.0
	return s


static func make_toolbar_style() -> StyleBoxFlat:
	## XP-style info bar — blue like a title bar area
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.10, 0.32, 0.72, 0.85)
	s.border_color = Color(0.25, 0.50, 0.90)
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_width_left = 0
	s.border_width_right = 0
	s.set_corner_radius_all(0)
	s.content_margin_left = 8.0
	s.content_margin_right = 8.0
	s.content_margin_top = 3.0
	s.content_margin_bottom = 3.0
	s.shadow_color = Color(0.0, 0.0, 0.0, 0.15)
	s.shadow_size = 2
	return s


static func make_window_control_button(color: Color) -> StyleBoxFlat:
	## Tiny title bar control button (min/max/close)
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = Color(1.0, 1.0, 1.0, 0.4)
	s.set_border_width_all(1)
	s.set_corner_radius_all(3)
	s.content_margin_left = 4.0
	s.content_margin_right = 4.0
	s.content_margin_top = 1.0
	s.content_margin_bottom = 1.0
	return s


static func make_window_frame_style(base_color: Color = TITLE_BAR_BLUE) -> StyleBoxFlat:
	## Outer window frame: blue rounded border wrapping title bar + body, with drop shadow.
	## Authentic XP: the frame color matches the title bar, creating a unified look.
	var s := StyleBoxFlat.new()
	s.bg_color = base_color.darkened(0.15)
	# Rounded top corners (title bar area), subtle bottom corners
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 4
	s.corner_radius_bottom_right = 4
	# Outer highlight: lighter edge for the 3D raised look
	s.border_color = base_color.lightened(0.25)
	s.border_width_top = 1
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_bottom = 1
	# Drop shadow
	s.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	s.shadow_size = 4
	s.shadow_offset = Vector2(2, 2)
	# Content margins create the visible frame border (3px blue edges)
	s.content_margin_left = 3.0
	s.content_margin_right = 3.0
	s.content_margin_bottom = 3.0
	s.content_margin_top = 0.0  # Title bar extends to the top edge
	return s


static func make_window_inner_body_style() -> StyleBoxFlat:
	## Inner window body: beige panel sitting inside the outer blue frame.
	## No side/bottom borders needed — the outer frame provides those.
	var s := StyleBoxFlat.new()
	s.bg_color = WINDOW_BG
	s.content_margin_left = 2.0
	s.content_margin_right = 2.0
	s.content_margin_top = 0.0
	s.content_margin_bottom = 2.0
	return s


static func make_sunken_panel_style() -> StyleBoxFlat:
	## Classic XP inset/sunken panel (like the calculator display area).
	## Dark border on top/left, lighter on bottom/right for 3D depth.
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.96, 0.95, 0.92)
	s.border_color = Color(0.55, 0.55, 0.50)
	s.border_width_top = 1
	s.border_width_left = 1
	s.border_width_bottom = 1
	s.border_width_right = 1
	s.content_margin_left = 1.0
	s.content_margin_right = 1.0
	s.content_margin_top = 1.0
	s.content_margin_bottom = 1.0
	return s


static func make_xp_close_button_style() -> StyleBoxFlat:
	## Authentic XP close button: red gradient, rounded, with beveled edges.
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.82, 0.34, 0.28)
	# 3D bevel: lighter top/left, darker bottom/right
	s.border_color = Color(0.95, 0.55, 0.45)
	s.border_width_top = 1
	s.border_width_left = 1
	s.border_width_bottom = 1
	s.border_width_right = 1
	s.set_corner_radius_all(3)
	s.content_margin_left = 6.0
	s.content_margin_right = 6.0
	s.content_margin_top = 2.0
	s.content_margin_bottom = 2.0
	return s


static func make_xp_caption_button_style(base_color: Color = TITLE_BAR_BLUE) -> StyleBoxFlat:
	## Authentic XP minimize/maximize button: blue gradient, rounded, beveled.
	var s := StyleBoxFlat.new()
	s.bg_color = base_color.lightened(0.15)
	s.border_color = base_color.lightened(0.45)
	s.border_width_top = 1
	s.border_width_left = 1
	s.border_width_bottom = 1
	s.border_width_right = 1
	s.set_corner_radius_all(3)
	s.content_margin_left = 6.0
	s.content_margin_right = 6.0
	s.content_margin_top = 2.0
	s.content_margin_bottom = 2.0
	return s
