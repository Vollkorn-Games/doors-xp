---
name: godot-4-6
description: Comprehensive Godot 4.6 game engine development skill. Provides GDScript syntax, TileMapLayer API, scene architecture, resource system, input handling, autoloads, signals, and common pitfalls for Godot 4.6. Use when working on any Godot 4.6 project - writing GDScript code, creating scenes, editing .tscn/.tres files, configuring project.godot, building game systems, or debugging Godot-specific issues. Triggers on any Godot game development task.
---

# Godot 4.6 Development

## Core Rules

1. **Always use static typing** - typed GDScript is up to 2x faster
2. **Use TileMapLayer, not TileMap** - TileMap is deprecated since 4.3
3. **Use annotation syntax** - `@export`, `@onready`, `@tool` (not keywords)
4. **Use new signal syntax** - `signal.connect(callable)`, `signal.emit()`
5. **Call down, signal up** - parents call children, children emit signals
6. **Never combine @onready with @export** - @onready overrides exported values

## Project Structure Convention

```
res://
  scenes/         .tscn scene files with co-located .gd scripts
  scripts/
    autoload/     singleton scripts (registered in project.godot)
    data/         class_name Resource definitions
    systems/      game system logic
  resources/      .tres data files (organized by type)
  assets/
    sprites/      textures, spritesheets
    tilesets/     tileset resources
    audio/        sound effects, music
```

## Reference Files

Consult these based on the task at hand:

- **GDScript syntax, annotations, signals, typed collections, lambdas, await, match, abstract classes, file structure convention** - See [references/gdscript.md](references/gdscript.md)
- **TileMapLayer API, cell methods, coordinate conversion, terrains, custom data, migration from TileMap** - See [references/tilemaplayer.md](references/tilemaplayer.md)
- **Scene organization, autoloads, event bus, resource system, input handling, grid movement, turn-based patterns, AStar2D, fog of war** - See [references/architecture.md](references/architecture.md)
- **Common pitfalls, deprecated API, 4.6 breaking changes, new 4.6 features** - See [references/pitfalls.md](references/pitfalls.md)

## Quick Patterns

### Typed function
```gdscript
func calculate(base: float, mult: float) -> float:
    return base * mult
```

### Export with range
```gdscript
@export_range(0, 100, 1, "or_greater") var hp: int = 100
```

### Signal connect
```gdscript
$Button.pressed.connect(_on_pressed)
health_changed.emit(current_health)
```

### TileMapLayer cell
```gdscript
layer.set_cell(Vector2i(x, y), source_id, atlas_coords)
var pos: Vector2 = layer.map_to_local(Vector2i(x, y))
var cell: Vector2i = layer.local_to_map(world_pos)
```

### Resource definition
```gdscript
class_name CardData
extends Resource
@export var card_name: String
@export var mp_cost: int
```

### Autoload access
```gdscript
GameState.score += 100
Events.enemy_died.emit(self, global_position)
```

## Writing .tscn Files

When creating scenes as text, use this format:

```
[gd_scene load_steps=2 format=3 uid="uid://xxxxx"]

[ext_resource type="Script" path="res://scripts/player.gd" id="1"]

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
```

Key rules for .tscn:
- `load_steps` = total ext_resources + sub_resources + 1
- Root node has no `parent` attribute
- Direct children use `parent="."`
- Deeper children use `parent="ParentName"` or `parent="Grand/Parent"`
- Properties only listed when they differ from defaults

## Writing project.godot

```ini
[autoload]
GameState="*res://scripts/autoload/game_state.gd"

[input]
move_up={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)]
}

[display]
window/size/viewport_width=480
window/size/viewport_height=320
window/stretch/mode="viewport"
```

For pixel art games, set stretch mode to "viewport" and configure a small viewport size.
