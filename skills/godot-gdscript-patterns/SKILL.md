---
name: godot-gdscript-patterns
description: "GDScript best practices for Godot 4.x: node composition, typed signals, scene instantiation, resource management, singletons, event buses, and common design patterns. Use when writing or reviewing GDScript code in Godot."
license: MIT
compatibility:
  - godot-4.0
  - godot-4.1
  - godot-4.2
  - godot-4.3
  - godot-4.4
  - godot-4.5
  - godot-4.6
  - godot-4.7
metadata:
  author: vl4dt
  version: 0.1.0
  tags:
    - godot
    - gdscript
    - design-patterns
    - signals
  created: 2026-06-20
---

# GDScript Patterns for Godot 4.x

Best practices and patterns for writing clean, maintainable GDScript code.

## Node Hierarchy Best Practices

### Composition Over Inheritance

```gdscript
# Good: Small, focused scenes composed together
# Player.tscn contains:
# - CharacterBody2D (root)
#   - Sprite2D (visual)
#   - CollisionShape2D (physics)
#   - AnimatedSprite2D (animation)
#   - HealthComponent (Node — logic)
#   - InventoryComponent (Node — logic)

# Avoid: Deep inheritance chains
# Player extends CharacterBody2D extends Node2D...
```

### Scene Instantiation Patterns

```gdscript
# preload() — Compile-time, for always-needed resources
@onready var bullet_scene = preload("res://scenes/entities/bullet.tscn")

# load() — Runtime, for conditional loading
var dialog_scene = load("res://scenes/ui/dialog.tscn")

# instantiate() — Create instance from scene
func spawn_bullet():
    var bullet = bullet_scene.instantiate()
    add_child(bullet)
```

## Typed Signals (Godot 4.x)

### Declaring Typed Signals

```gdscript
# Godot 4.x typed signal syntax
signal health_changed(new_health: int, max_health: int)
signal player_died(position: Vector2)
signal item_collected(item_data: Resource)
```

### Connecting Signals

```gdscript
# Auto-connect in editor (rename method to on_NodeName_signal)
func _on_health_changed(new_health: int, _max_health: int):
    update_health_bar(new_health)

# Manual connection
func _ready():
    enemy.health_depleted.connect(_on_enemy_defeated)

# Callable syntax (Godot 4.x)
button.pressed.connect(func: do_something())
```

## Scene Loading Patterns

### Resource Loading

```gdscript
# Preload for compile-time constants
const PlayerScene = preload("res://scenes/entities/player.tscn")

# Load for runtime/conditional loading
func load_level(level_name: String):
    var path = "res://levels/%s.tscn" % level_name
    var scene = load(path)
    if scene:
        current_level = scene.instantiate()
        add_child(current_level)
```

### Resource Management

```gdscript
# Use Resource for game data
@export_file("*.tres") var player_data: String
var data: PlayerData = load(player_data) as PlayerData

# Scene packs for level data
var level_pack = preload("res://resources/data/level_pack.tscn")
```

## Common Patterns

### Singleton (Autoload) Pattern

```gdscript
# Add to Project Settings > Autoload as "GameData"
class_name GameData extends Node

var player_score: int = 0
var high_score: int = 0

func add_score(points: int):
    player_score += points
    if player_score > high_score:
        high_score = player_score
```

### Event Bus Pattern

```gdscript
# Add to Project Settings > Autoload as "EventBus"
class_name EventBus extends Node

signal game_started()
signal level_completed(level_id: int)
signal player_died()
signal game_paused(paused: bool)

# Usage in any script
func _ready():
    EventBus.level_completed.connect(on_level_completed)
```

### Node Path Best Practices

```gdscript
# Good: Use @onready for scene tree paths
@onready var health_bar = $UI/HealthBar as ProgressBar
@onready var sprite = $Sprite2D as Sprite2D

# Avoid: Hardcoded paths
var health_bar = get_node("UI/HealthBar")  # Fragile to hierarchy changes
```

## Godot 4.7 GDScript Notes

- **DrawableTexture2D** — Create dynamic textures at runtime for procedural rendering
- **tween_await()** — Use await with tweens for sequential animations
- **Typed signals** are now the standard — prefer typed over untyped

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools can inspect and modify your project live:

- **`script_read`** — Read any script file from the project
- **`script_edit`** — Write updated script contents directly to disk
- **`script_validate`** — Validate GDScript syntax with `suggestTweenAwait: true` for Godot 4.7 migration
- **`scene_tree`** — Inspect the current scene hierarchy
- **`class_db_info`** — Query available methods/properties on any Godot class

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [GDScript Style Guide](references/gdscript-style.md)
- [Signal Patterns Deep Dive](references/signals.md)
- [Resource Management](references/resource-management.md)
