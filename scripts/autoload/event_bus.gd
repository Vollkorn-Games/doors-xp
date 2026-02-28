extends Node

## Global signal bus for decoupled communication between game systems.

# Task lifecycle
signal task_spawned(slot_index: int, task_data: Resource)
signal task_activated(slot_index: int)
signal task_step_completed(slot_index: int, step_index: int)
signal task_completed(slot_index: int, task_data: Resource, perfect: bool)
signal task_failed(slot_index: int, task_data: Resource)
signal task_mistake(slot_index: int)

# Game flow
signal day_started(day_number: int)
signal day_ended(day_number: int)
signal game_over()

# Scoring
signal score_changed(new_score: int)
signal reputation_changed(new_reputation: float)
signal combo_changed(new_combo: int)

# UI
signal show_day_summary(stats: Dictionary)
