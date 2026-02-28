extends Node

## Manages task spawning, active task slots, and task lifecycle.
## This is the "kitchen" - controls game pacing and difficulty.

const MAX_SLOTS := 8

var _task_pool: Array[Resource] = []
var _slot_data: Array = []  # Resource per slot (null if empty)
var _slot_time: Array[float] = []     # Time remaining per slot
var _spawn_timer: float = 0.0
var _day_active: bool = false
var _day_time_remaining: float = 0.0
var _day_total_time: float = 0.0


func _ready() -> void:
	_slot_data.resize(MAX_SLOTS)
	_slot_time.resize(MAX_SLOTS)
	for i in range(MAX_SLOTS):
		_slot_data[i] = null
		_slot_time[i] = 0.0

	GameManager.state_changed.connect(_on_game_state_changed)


func _process(delta: float) -> void:
	if not _day_active:
		return

	# Day timer
	_day_time_remaining -= delta
	if _day_time_remaining <= 0.0:
		_end_day()
		return

	# Spawn timer
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_try_spawn_task()
		_spawn_timer = _get_current_spawn_interval()

	# Update patience for all active slots
	for i in range(MAX_SLOTS):
		if _slot_data[i] != null:
			_slot_time[i] -= delta
			if _slot_time[i] <= 0.0:
				_fail_slot(i)


func start_day() -> void:
	_load_task_pool()
	_day_total_time = GameManager.DAY_DURATION
	_day_time_remaining = _day_total_time
	_spawn_timer = 2.0  # Short delay before first task
	_day_active = true

	# Clear all slots
	for i in range(MAX_SLOTS):
		_slot_data[i] = null
		_slot_time[i] = 0.0

	EventBus.day_started.emit(GameManager.current_day)


func get_slot_data(slot: int) -> Resource:
	if slot < 0 or slot >= MAX_SLOTS:
		return null
	return _slot_data[slot]


func get_slot_patience_ratio(slot: int) -> float:
	if slot < 0 or slot >= MAX_SLOTS or _slot_data[slot] == null:
		return 0.0
	return clampf(_slot_time[slot] / _slot_data[slot].time_limit, 0.0, 1.0)


func get_day_time_remaining() -> float:
	return maxf(_day_time_remaining, 0.0)


func get_day_time_ratio() -> float:
	if _day_total_time <= 0.0:
		return 0.0
	return clampf(_day_time_remaining / _day_total_time, 0.0, 1.0)


func complete_slot(slot: int, perfect: bool) -> void:
	if slot < 0 or slot >= MAX_SLOTS or _slot_data[slot] == null:
		return
	var td: Resource = _slot_data[slot]
	_slot_data[slot] = null
	_slot_time[slot] = 0.0
	EventBus.task_completed.emit(slot, td, perfect)


func fail_slot(slot: int) -> void:
	_fail_slot(slot)


func _fail_slot(slot: int) -> void:
	if slot < 0 or slot >= MAX_SLOTS or _slot_data[slot] == null:
		return
	var td: Resource = _slot_data[slot]
	_slot_data[slot] = null
	_slot_time[slot] = 0.0
	EventBus.task_failed.emit(slot, td)


func _load_task_pool() -> void:
	_task_pool.clear()
	var dir := DirAccess.open("res://resources/tasks/")
	if dir == null:
		push_error("TaskManager: Could not open res://resources/tasks/")
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var task: Resource = load("res://resources/tasks/" + file_name)
			if task:
				_task_pool.append(task)
		file_name = dir.get_next()
	dir.list_dir_end()


func _try_spawn_task() -> void:
	var active_count := _get_active_count()
	if active_count >= GameManager.max_simultaneous_tasks:
		return

	var free_slot := _find_free_slot()
	if free_slot < 0:
		return

	var task_data := _pick_task()
	if task_data == null:
		return

	# Apply difficulty modifier to time limit
	var modified_data: Resource = task_data.duplicate()
	modified_data.time_limit *= GameManager.time_limit_modifier

	_slot_data[free_slot] = modified_data
	_slot_time[free_slot] = modified_data.time_limit
	EventBus.task_spawned.emit(free_slot, modified_data)


func _find_free_slot() -> int:
	for i in range(MAX_SLOTS):
		if _slot_data[i] == null:
			return i
	return -1


func _get_active_count() -> int:
	var count := 0
	for i in range(MAX_SLOTS):
		if _slot_data[i] != null:
			count += 1
	return count


func _pick_task() -> Resource:
	var eligible: Array[Resource] = []
	for td: Resource in _task_pool:
		if td.difficulty <= GameManager.current_difficulty:
			eligible.append(td)
	if eligible.is_empty():
		return null
	return eligible[randi() % eligible.size()]


func _get_current_spawn_interval() -> float:
	var base: float = GameManager.spawn_interval
	# Rush hour: middle third of the day, spawn interval halves
	var day_progress: float = 1.0 - get_day_time_ratio()
	if day_progress > 0.33 and day_progress < 0.66:
		base *= 0.5
	return base


func _end_day() -> void:
	_day_active = false
	# Fail any remaining active tasks silently (don't penalize)
	for i in range(MAX_SLOTS):
		_slot_data[i] = null
		_slot_time[i] = 0.0
	GameManager.end_day()


func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.PLAYING:
		start_day()
	elif new_state != GameManager.GameState.PLAYING:
		_day_active = false
