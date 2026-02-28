extends Control

## Game Over screen styled as a Windows XP Blue Screen of Death.

const _XPTheme := preload("res://scripts/ui/xp_theme_builder.gd")

var _text_label: Label
var _stats_label: Label
var _prompt_label: Label
var _blink_timer: float = 0.0


func _ready() -> void:
	_build_ui()
	_populate_stats()


func _process(delta: float) -> void:
	# Blink the "press any key" text
	_blink_timer += delta
	if _prompt_label:
		_prompt_label.visible = fmod(_blink_timer, 1.0) < 0.7


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event.pressed and not key_event.echo:
		GameManager.change_state(GameManager.GameState.MENU)
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	# BSOD blue background
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.67)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 80)
	margin.add_theme_constant_override("margin_right", 80)
	margin.add_theme_constant_override("margin_top", 60)
	margin.add_theme_constant_override("margin_bottom", 60)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "  Doors XP  "
	title.add_theme_color_override("font_color", Color(0.0, 0.0, 0.67))
	title.add_theme_font_size_override("font_size", 18)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Title background (white text on dark = reversed for BSOD header)
	var title_panel := PanelContainer.new()
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.75, 0.75, 0.75)
	title_style.content_margin_left = 8.0
	title_style.content_margin_right = 8.0
	title_style.content_margin_top = 2.0
	title_style.content_margin_bottom = 2.0
	title_panel.add_theme_stylebox_override("panel", title_style)
	title_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	title_panel.add_child(title)
	vbox.add_child(title_panel)

	# Error message
	_text_label = Label.new()
	_text_label.text = "A fatal exception has occurred in your work performance.\nThe current session will be terminated.\n\n*  Your reputation has dropped below acceptable levels.\n*  All running tasks have been terminated.\n*  The IT department has been notified.\n\nIRQL_REPUTATION_NOT_SUFFICIENT (0x00000REP)"
	_text_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	_text_label.add_theme_font_size_override("font_size", 14)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_text_label)

	# Stats
	_stats_label = Label.new()
	_stats_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	_stats_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_stats_label)

	# Press any key prompt
	_prompt_label = Label.new()
	_prompt_label.text = "Press any key to restart the system..."
	_prompt_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	_prompt_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_prompt_label)


func _populate_stats() -> void:
	var stats: Dictionary = GameManager.day_stats
	_stats_label.text = "=== SESSION STATISTICS ===\n" \
		+ "Days Survived: %d\n" % GameManager.current_day \
		+ "Final Score: %d\n" % GameManager.score \
		+ "Tasks Completed Today: %d\n" % stats.get("completed", 0) \
		+ "Tasks Failed Today: %d\n" % stats.get("failed", 0) \
		+ "Final Reputation: %.0f / %.0f" % [GameManager.reputation, GameManager.MAX_REPUTATION]
