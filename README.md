# Doors XP

A **Cook, Serve, Delicious**-style task management game set on a Windows XP desktop. Juggle incoming OS tasks — read emails, fight viruses, print documents — by pressing the right keys in sequence before time runs out.

Built with **Godot 4.6** (GDScript).

## Gameplay

Tasks appear on your taskbar as tickets. Each one has a sequence of key presses to complete — just like preparing orders in CSD.

1. Press **1-8** to select a task from the taskbar
2. A window opens showing the steps and a key hint like `[R]`
3. Press the correct keys in order to complete the task
4. Score points, build combos, and keep your reputation up

Make too many mistakes and the task fails. Let your reputation drop to zero and it's game over.

### Shift Structure

Each work day is **6 minutes**. Tasks spawn faster as the day progresses, with a mid-day rush hour. After each day, a summary screen shows your stats before the next shift begins.

### Scoring

| Mechanic | Details |
|----------|---------|
| Base score | 80-150 points per task |
| Combo | +0.25x per consecutive completion (resets on fail) |
| Perfect bonus | 1.5x multiplier for zero-mistake tasks |
| Reputation | Starts at 50/100, game over at 10 |

### Difficulty Scaling

| | Day 1 | Day 2 | Day 3+ |
|--|-------|-------|--------|
| Spawn interval | 6s | 4.5s | 3s |
| Max tasks | 4 | 6 | 8 |
| Time pressure | Normal | 0.9x | 0.7x |

## Tasks

| Task | Keys | Time | Points |
|------|------|------|--------|
| Print Document | O → F → P → C → Enter | 40s | 80 |
| Read Email | O → R → S → C → Enter | 45s | 100 |
| Virus Alert | A → O → S → *(wait)* → Q → D | 50s | 150 |

## Running

Open the project in **Godot 4.6** and run the main scene (`scenes/main_menu.tscn`).

## License

All rights reserved. VollkornGames.
