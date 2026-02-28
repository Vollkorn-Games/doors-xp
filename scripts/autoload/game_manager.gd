extends Node

## Tracks score, reputation, day progress, and overall game state.

signal state_changed(new_state: GameState)

enum GameState { MENU, PLAYING, DAY_END, GAME_OVER }

const STARTING_REPUTATION := 50.0
const MAX_REPUTATION := 100.0
const GAME_OVER_REPUTATION := 10.0
const COMBO_MULTIPLIER_INCREMENT := 0.25
const DAY_DURATION := 360.0 # 6 minutes

var current_state: GameState = GameState.MENU

var current_day: int = 1

var score: int = 0:
	set(value):
		score = value
		EventBus.score_changed.emit(score)

var reputation: float = STARTING_REPUTATION:
	set(value):
		reputation = clampf(value, 0.0, MAX_REPUTATION)
		EventBus.reputation_changed.emit(reputation)
		if reputation <= GAME_OVER_REPUTATION and current_state == GameState.PLAYING:
			_trigger_game_over()

var combo: int = 0:
	set(value):
		combo = value
		EventBus.combo_changed.emit(combo)

var day_stats: Dictionary = {}

var current_difficulty: int:
	get:
		return mini(current_day, 3)

var spawn_interval: float:
	get:
		match current_difficulty:
			1: return 6.0
			2: return 4.5
			_: return 3.0

var time_limit_modifier: float:
	get:
		match current_difficulty:
			1: return 1.0
			2: return 0.9
			_: return 0.7

var max_simultaneous_tasks: int:
	get:
		match current_difficulty:
			1: return 4
			2: return 6
			_: return 8


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_signals()


func _connect_signals() -> void:
	EventBus.task_completed.connect(_on_task_completed)
	EventBus.task_failed.connect(_on_task_failed)
	EventBus.task_mistake.connect(_on_task_mistake)


func start_new_game() -> void:
	current_day = 1
	score = 0
	reputation = STARTING_REPUTATION
	combo = 0
	day_stats = {}
	change_state(GameState.PLAYING)


func start_next_day() -> void:
	current_day += 1
	day_stats = {}
	combo = 0
	change_state(GameState.PLAYING)


func end_day() -> void:
	change_state(GameState.DAY_END)
	EventBus.day_ended.emit(current_day)
	EventBus.show_day_summary.emit(day_stats)


func change_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(new_state)


func _on_task_completed(_slot_index: int, task_data: Resource, perfect: bool) -> void:
	combo += 1
	var combo_multiplier: float = 1.0 + (combo - 1) * COMBO_MULTIPLIER_INCREMENT
	var points: int = int(task_data.base_score * combo_multiplier)
	if perfect:
		points = int(points * 1.5)
	score += points
	reputation += task_data.reputation_reward

	day_stats["completed"] = day_stats.get("completed", 0) + 1
	if perfect:
		day_stats["perfect"] = day_stats.get("perfect", 0) + 1
	day_stats["score"] = day_stats.get("score", 0) + points


func _on_task_failed(_slot_index: int, task_data: Resource) -> void:
	combo = 0
	reputation -= task_data.reputation_penalty
	day_stats["failed"] = day_stats.get("failed", 0) + 1


func _on_task_mistake(_slot_index: int) -> void:
	combo = 0


func _trigger_game_over() -> void:
	change_state(GameState.GAME_OVER)
	EventBus.game_over.emit()
