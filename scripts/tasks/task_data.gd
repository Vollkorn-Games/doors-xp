class_name TaskData
extends Resource

## Defines a complete task type (like a "recipe" in Cook Serve Delicious).

@export var task_name: String = ""
@export var task_id: StringName = &""
@export_multiline var description: String = ""
@export var steps: Array[Resource] = []
@export var time_limit: float = 30.0
@export var base_score: int = 100
@export var mistake_penalty: int = 25
@export var max_mistakes: int = 3
@export_range(1, 5) var difficulty: int = 1
@export var task_color: Color = Color(0.0, 0.34, 0.84)  ## Title bar / accent color
@export var reputation_reward: float = 0.1
@export var reputation_penalty: float = 0.15

func get_total_steps() -> int:
	return steps.size()
