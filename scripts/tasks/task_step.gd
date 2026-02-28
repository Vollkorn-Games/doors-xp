class_name TaskStep
extends Resource

## A single step within a task sequence.

## What displays on screen, e.g. "Open Inbox"
@export var label: String = ""

## The key to press, e.g. "o", "enter", "space"
@export var key_action: String = ""

## Flavor text shown below the step
@export var description: String = ""

## If true, this step auto-completes after wait_time seconds
@export var is_timed_wait: bool = false

## Seconds to wait if is_timed_wait is true
@export var wait_time: float = 0.0
