extends Control

## Main menu styled as the Windows XP login screen.

const _XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")

@onready var _start_button: Button = %StartButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	theme = _XPTheme.build_theme()
	_setup_login_style()
	_start_button.pressed.connect(_on_start)
	_quit_button.pressed.connect(_on_quit)
	_start_button.grab_focus()


func _setup_login_style() -> void:
	# Add XP-style blue welcome banner across the top of the screen
	var banner := PanelContainer.new()
	var banner_style := StyleBoxFlat.new()
	banner_style.bg_color = Color(0.0, 0.2, 0.55)
	banner_style.border_color = Color(0.3, 0.5, 0.85)
	banner_style.border_width_top = 2
	banner_style.border_width_bottom = 2
	banner_style.content_margin_left = 20.0
	banner_style.content_margin_right = 20.0
	banner_style.content_margin_top = 12.0
	banner_style.content_margin_bottom = 12.0
	banner.add_theme_stylebox_override("panel", banner_style)
	banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	banner.offset_top = 40.0
	banner.offset_bottom = 100.0

	var banner_label := Label.new()
	banner_label.text = "To begin, click your user name"
	banner_label.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	banner_label.add_theme_font_size_override("font_size", 18)
	banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.add_child(banner_label)
	add_child(banner)

	# Style the user icon with a blue border (XP user avatar)
	var user_icon: PanelContainer = $CenterContainer/LoginPanel/VBox/UserIcon
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = Color(0.88, 0.9, 0.92)
	icon_style.border_color = _XPTheme.TITLE_BAR_BLUE
	icon_style.set_border_width_all(3)
	icon_style.set_corner_radius_all(4)
	user_icon.add_theme_stylebox_override("panel", icon_style)


func _on_start() -> void:
	GameManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/desktop.tscn")


func _on_quit() -> void:
	get_tree().quit()
