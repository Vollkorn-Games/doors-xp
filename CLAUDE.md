# Doors XP

Cook, Serve, Delicious-style task management game in Godot 4.6 with a Windows XP desktop theme. Players juggle OS-related tasks (reading email, fighting viruses, printing documents) that arrive as "tickets" with step-by-step key sequences to complete.

## Tech Stack

- **Engine**: Godot 4.6 (GDScript, GL Compatibility renderer)
- **Resolution**: 1024x768, canvas_items stretch mode
- **Build tools**: Godot MCP server at `../godot-mcp` (68 tools for scene/script/interactive ops)
- **Project path for MCP tools**: `C:\Users\sasch\Documents\GitHub\VollkornGames\doors-xp`

## Architecture

```
Autoloads (global singletons, loaded in this order):
  EventBus    → scripts/autoload/event_bus.gd    (signal bus)
  GameManager → scripts/autoload/game_manager.gd (score, reputation, state machine)
  TaskManager → scripts/autoload/task_manager.gd (spawning, slots, timers)

Scene flow: MainMenu → Desktop (gameplay) → DaySummary → loop back to Desktop
```

### Directory Layout

```
scenes/              3 .tscn files (main_menu, desktop, day_summary)
scripts/autoload/    3 autoloads (event_bus, game_manager, task_manager)
scripts/tasks/       task_data.gd, task_step.gd, task_window.gd
scripts/ui/          desktop.gd, main_menu.gd, day_summary.gd, taskbar_button.gd, xp_theme_builder.gd
resources/tasks/     3 .tres task definitions (print_document, read_email, virus_alert)
```

## Core Loop

1. Tasks spawn on a taskbar (up to 8 slots) on a timer
2. Player presses **1-8** to select a task slot
3. A "window" opens showing the task's steps with a key hint like `[R]`
4. Player presses correct keys in sequence to complete steps
5. Task completes → score + combo. Mistakes → flash red, fail at max_mistakes.
6. Day ends after 360s → DaySummary screen → next day with harder params

### Input Flow

- `Desktop._unhandled_key_input()` catches all keys
- Keys 1-8 → slot selection via input actions `select_task_1` through `select_task_8`
- All other keys → forwarded to the active `TaskWindow.handle_key_input()`
- TaskWindow compares pressed key to `current_step.key_action` (lowercase string like "o", "enter")
- Task steps only use letters (a-z), Enter, Space — **no number keys** (reserved for slots)

### Signal Flow

All cross-system communication goes through `EventBus` signals. Key signals:
- `task_spawned(slot, task_data)` — TaskManager → Desktop (creates taskbar button)
- `task_completed(slot, task_data, perfect)` — TaskManager → GameManager (scoring)
- `task_failed(slot, task_data)` — TaskManager → GameManager (reputation loss)
- `score_changed`, `reputation_changed`, `combo_changed` — GameManager → Desktop (HUD updates)
- `show_day_summary(stats)` — GameManager → Desktop (scene transition)

## Game Balance

| Parameter | Day 1 | Day 2 | Day 3+ |
|-----------|-------|-------|--------|
| Spawn interval | 6s | 4.5s | 3s |
| Max simultaneous | 4 | 6 | 8 |
| Time modifier | 1.0x | 0.9x | 0.7x |
| Max difficulty tier | 1 | 2 | 3 |

- **Rush hour**: Middle third of day (33%-66%), spawn interval halves
- **Combo**: +0.25x per consecutive completion, resets on fail or mistake
- **Perfect bonus**: 1.5x if zero mistakes
- **Reputation**: Starts 50, max 100, game over at ≤10

### Current Tasks

| Task | Steps | Time | Score | Difficulty |
|------|-------|------|-------|------------|
| Print Document | O→F→P→C→Enter | 40s | 80 | 1 |
| Read Email | O→R→S→C→Enter | 45s | 100 | 1 |
| Virus Alert | A→O→S→(wait 2s)→Q→D | 50s | 150 | 1 |

## Key Design Decisions

1. **TaskManager is single source of truth for time** — TaskWindow reads patience from `TaskManager.get_slot_patience_ratio()`, no dual timers
2. **TaskData.duplicate() on spawn** — Prevents shared Resource state between active tasks
3. **EventBus uses `Resource` type** (not class_names) — Autoloads load before class_names are registered in Godot 4.6
4. **`preload()` instead of class_name references** — Same reason; use `const Foo := preload("res://path.gd")`
5. **Theme inheritance** — XPThemeBuilder.build_theme() set on scene root, all children inherit
6. **All UI built programmatically** — TaskWindow._build_ui() creates its node tree in code, not in the scene editor

## Godot 4.6 Gotchas

- **class_name resolution**: Autoloads load before class_names. Use `preload()` and `Resource`/`Array[Resource]` instead.
- **Integer division**: GDScript warns on `int / int`. Use `@warning_ignore("integer_division")`.
- **MCP stale autoload**: `run_interactive` injects `_McpInputReceiver` into project.godot. If it persists after stopping, remove the line manually.

## Status

**Phase 1 MVP: Complete.** Core loop is verified end-to-end: spawn → select → key sequence → score → day summary → next day.

### What's Missing (Phase 2+ ideas)

- More task types (defrag, install software, organize files, etc.)
- Difficulty 2-3 tasks with more steps / shorter timers
- Sound effects and music
- Visual polish (animations, particles, transitions)
- Upgrades/shop between days
- Persistent high scores / save system
- Tutorial / first-time player experience
- More XP theming (desktop icons, error dialogs as events)

## Working With This Project

### Adding a New Task

1. Create `resources/tasks/my_task.tres` — set task_name, steps (Array of TaskStep sub-resources), time_limit, base_score, difficulty, etc.
2. Each TaskStep needs: label, key_action (lowercase letter or "enter"/"space"), optionally is_timed_wait + wait_time
3. TaskManager auto-discovers all `.tres` files in `resources/tasks/` on day start
4. Set difficulty ≥ 2 to make it appear only on day 2+

### Using MCP Tools

```
projectPath: "C:\\Users\\sasch\\Documents\\GitHub\\VollkornGames\\doors-xp"
```

Useful workflows:
- `write_script` / `read_script` — edit GDScript files
- `validate_script` — check syntax without running
- `run_interactive` + `send_key` — play-test the game
- `game_screenshot` — see what the game looks like at runtime
- `capture_screenshot` — render a scene statically
- `validate_scene` — check for broken references
- `get_scene_tree` / `get_scene_insights` — understand scene structure
