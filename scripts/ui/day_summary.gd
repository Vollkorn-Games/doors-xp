extends Control

## Day summary screen - shows results after each shift ends.
## Styled as a Windows XP "System Properties" dialog.

const _XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")

@onready var _title_label: Label = %TitleLabel
@onready var _completed_label: Label = %CompletedLabel
@onready var _perfect_label: Label = %PerfectLabel
@onready var _failed_label: Label = %FailedLabel
@onready var _day_score_label: Label = %DayScoreLabel
@onready var _total_score_label: Label = %TotalScoreLabel
@onready var _reputation_bar: ProgressBar = %ReputationBar
@onready var _continue_button: Button = %ContinueButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	theme = _XPTheme.build_theme()
	_apply_xp_styles()
	_populate_stats()
	_continue_button.pressed.connect(_on_continue)
	_quit_button.pressed.connect(_on_quit)
	_continue_button.grab_focus()


func _apply_xp_styles() -> void:
	var title_bar: PanelContainer = %TitleBar
	title_bar.add_theme_stylebox_override("panel", _XPTheme.make_title_bar_style())

	_title_label.add_theme_color_override("font_color", _XPTheme.TEXT_WHITE)
	_title_label.add_theme_font_size_override("font_size", 13)

	var window: PanelContainer = %Window
	window.add_theme_stylebox_override("panel", _XPTheme.make_window_body_style())


func _populate_stats() -> void:
	var stats: Dictionary = GameManager.day_stats

	_title_label.text = "Day %d - Shift Complete" % GameManager.current_day
	_completed_label.text = "Tasks Completed: %d" % stats.get("completed", 0)
	_perfect_label.text = "Perfect Tasks: %d" % stats.get("perfect", 0)
	_failed_label.text = "Tasks Failed: %d" % stats.get("failed", 0)
	_day_score_label.text = "Day Score: %d" % stats.get("score", 0)
	_total_score_label.text = "Total Score: %d" % GameManager.score
	_reputation_bar.max_value = GameManager.MAX_REPUTATION
	_reputation_bar.value = GameManager.reputation


func _on_continue() -> void:
	GameManager.start_next_day()
	get_tree().change_scene_to_file("res://scenes/desktop.tscn")


func _on_quit() -> void:
	GameManager.change_state(GameManager.GameState.MENU)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
