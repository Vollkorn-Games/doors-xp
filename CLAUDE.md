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
scenes/              4 .tscn files (main_menu, desktop, day_summary, game_over)
scripts/autoload/    3 autoloads (event_bus, game_manager, task_manager)
scripts/tasks/       task_data.gd, task_step.gd, task_window.gd
scripts/ui/          desktop.gd, main_menu.gd, day_summary.gd, game_over.gd, taskbar_button.gd, score_popup.gd, xp_theme_builder.gd
resources/tasks/     7 .tres task definitions (print_document, read_email, virus_alert, organize_files, install_software, defrag_hdd, blue_screen_fix)
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

| Task | Steps | Time | Score | Diff | Color |
|------|-------|------|-------|------|-------|
| Read Email | O→R→S→C→Enter | 45s | 100 | 1 | Blue |
| Print Document | O→F→P→C→(wait 1.5s)→Enter | 40s | 80 | 1 | Brown |
| Organize Files | E→A→X→O→V→(wait 1s)→Enter | 35s | 100 | 1 | Gold |
| Virus Alert | A→O→S→(wait 2s)→Q→D | 50s | 150 | 2 | Red |
| Install Software | I→R→A→C→N→(wait 2.5s)→Enter | 50s | 160 | 2 | Green |
| Defrag HDD | M→R→P→T→(wait 2s)→D→(wait 3s)→Enter | 50s | 200 | 2 | Purple |
| Blue Screen Fix | Space→F→(wait 2s)→D→U→I→(wait 2s)→R→Enter | 55s | 250 | 3 | Dark Blue |

Each task has a unique `task_color` that tints its title bar, window border, key hints, and taskbar button.

## Key Design Decisions

1. **TaskManager is single source of truth for time** — TaskWindow reads patience from `TaskManager.get_slot_patience_ratio()`, no dual timers
2. **TaskData.duplicate() on spawn** — Prevents shared Resource state between active tasks
3. **EventBus uses `Resource` type** (not class_names) — Autoloads load before class_names are registered in Godot 4.6
4. **`preload()` instead of class_name references** — Same reason; use `const Foo := preload("res://path.gd")`
5. **Theme inheritance** — XPThemeBuilder.build_theme() set on scene root, all children inherit
6. **All UI built programmatically** — TaskWindow._build_ui() creates its node tree in code, not in the scene editor

## Godot 4.6 Gotchas

- **class_name resolution**: Autoloads load before class_names. Use `preload()` and `Resource`/`Array[Resource]` instead.
- **class_name self-reference in static methods**: A script cannot reference its own `class_name` in a static factory method. Use `const _Self := preload("res://path/to/self.gd")` and `_Self.new()` instead.
- **Integer division**: GDScript warns on `int / int`. Use `@warning_ignore("integer_division")`.
- **MCP stale autoload**: `run_interactive` injects `_McpInputReceiver` into project.godot. If it persists after stopping, remove the line manually.

## Status

**Phase 2 in progress.** Core loop verified. Visual polish and content expansion underway.

### Phase 2 additions (done)
- 4 new task types: Organize Files, Install Software, Defrag HDD, Blue Screen Fix
- Floating score popup on task completion (+120 rises and fades)
- Combo counter pulse animation (scale bounce on increment)
- Reputation bar color changes (green → yellow → red based on value)
- Task window "Step N/M" progress counter in title bar
- Task window "DONE!" / "PERFECT!" flash on completion
- Desktop icons: My Computer, My Documents, Recycle Bin, Internet Explorer, Control Panel
- Game Over screen: BSOD-style with session stats and "press any key" prompt
- New scene: `scenes/game_over.tscn` with `scripts/ui/game_over.gd`
- New script: `scripts/ui/score_popup.gd` (floating score text)
- Per-task color coding: title bar, window border, key hints, taskbar buttons tinted by task_color
- Step description flavor text shown in task window below key hint
- Task mechanical differentiation: Print/Organize/Defrag now have unique timed waits
- Difficulty rebalance: Virus Alert → diff 2, Organize Files → diff 1 (4 diff-1, 3 diff-2, 1 diff-3 → better day-1 variety)

### What's Missing (Phase 3+ ideas)

- Sound effects and music
- More visual polish (window open/close animations, particles)
- Upgrades/shop between days
- Persistent high scores / save system
- Tutorial / first-time player experience
- More XP theming (error dialogs as random events, desktop wallpaper options)
- Additional task types (empty recycle bin, Windows Update, disk cleanup)

## Working With This Project

### Adding a New Task

1. Create `resources/tasks/my_task.tres` — set task_name, steps (Array of TaskStep sub-resources), time_limit, base_score, difficulty, task_color, etc.
2. Each TaskStep needs: label, key_action (lowercase letter or "enter"/"space"), description (flavor text), optionally is_timed_wait + wait_time
3. Set `task_color` to a unique Color — this tints the title bar, window border, key hints, and taskbar button
4. TaskManager auto-discovers all `.tres` files in `resources/tasks/` on day start
5. Set difficulty ≥ 2 to make it appear only on day 2+

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
