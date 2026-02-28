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
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_left = 0
	s.corner_radius_bottom_right = 0
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
	s.border_color = Color(0.08, 0.28, 0.7)
	s.border_width_top = 2
	s.content_margin_left = 4.0
	s.content_margin_right = 4.0
	s.content_margin_top = 2.0
	s.content_margin_bottom = 2.0
	return s


static func make_taskbar_button_normal() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.18, 0.45, 0.88)
	s.border_color = Color(0.1, 0.3, 0.7)
	s.set_border_width_all(1)
	s.set_corner_radius_all(2)
	s.content_margin_left = 6.0
	s.content_margin_right = 6.0
	s.content_margin_top = 3.0
	s.content_margin_bottom = 3.0
	return s


static func make_taskbar_button_selected() -> StyleBoxFlat:
	var s := make_taskbar_button_normal()
	s.bg_color = Color(0.22, 0.52, 0.95)
	s.border_color = Color(0.5, 0.7, 1.0)
	s.set_border_width_all(2)
	return s


static func make_taskbar_button_empty() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.15, 0.38, 0.78, 0.3)
	s.border_color = Color(0.1, 0.3, 0.65, 0.3)
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
	s.border_color = Color(0.15, 0.5, 0.12)
	s.set_border_width_all(1)
	s.corner_radius_top_left = 8
	s.corner_radius_bottom_left = 8
	s.corner_radius_top_right = 4
	s.corner_radius_bottom_right = 4
	s.content_margin_left = 12.0
	s.content_margin_right = 12.0
	s.content_margin_top = 4.0
	s.content_margin_bottom = 4.0
	return s


static func make_start_button_hover() -> StyleBoxFlat:
	var s := make_start_button_style()
	s.bg_color = START_BUTTON_HOVER
	return s
