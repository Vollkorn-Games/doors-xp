extends Control

## Main menu styled as the Windows XP login screen.

const _XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")

@onready var _start_button: Button = %StartButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	theme = _XPTheme.build_theme()
	_start_button.pressed.connect(_on_start)
	_quit_button.pressed.connect(_on_quit)
	_start_button.grab_focus()


func _on_start() -> void:
	GameManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/desktop.tscn")


func _on_quit() -> void:
	get_tree().quit()
