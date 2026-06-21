---
name: godot-architecture
description: "Game architecture patterns for Godot 4.x: ECS-like composition, scene organization, dependency injection via signals, service locator vs direct reference, and scalable project structure. Use when designing or refactoring a Godot game's overall architecture."
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
    - architecture
    - ecs
    - composition
    - service-locator
  created: 2026-06-21
---

# Godot Game Architecture Patterns

Architectural approaches for building scalable, maintainable Godot games.

## Scene Composition Over Inheritance

Godot's scene system naturally supports composition. Build complex behavior by combining small, focused scenes rather than deep inheritance chains.

### Component-Based Composition

```gdscript
# Player.tscn hierarchy:
# CharacterBody2D (root — movement logic)
#   Sprite2D (visual)
#   CollisionShape2D (physics body)
#   HealthComponent (Node — health logic, emits signals)
#   InventoryComponent (Node — item management)
#   ExperienceComponent (Node — XP/leveling)

# Each component is a standalone .tscn with its own script.
# The player scene composes them without inheritance coupling.
```

### Component Script Pattern

```gdscript
class_name HealthComponent extends Node

signal health_changed(current: int, maximum: int)
signal died()

@export var max_health: int = 100
var current_health: int = 100:
    set(value):
        current_health = clampi(value, 0, max_health)
        health_changed.emit(current_health, max_health)
        if current_health <= 0:
            died.emit()

func take_damage(amount: int) -> void:
    current_health -= amount

func heal(amount: int) -> void:
    current_health += amount
```

## Dependency Management Patterns

### Direct Reference (Simple Cases)

```gdscript
# Good for tightly-coupled parent-child relationships
@onready var health_component = $HealthComponent as HealthComponent
@onready var animation_player = $AnimationPlayer as AnimationPlayer
```

### Signal-Based Decoupling (Recommended)

```gdscript
# Components communicate via signals — no direct references needed
func _ready():
    $HealthComponent.died.connect(_on_player_died)
    $InventoryComponent.item_collected.connect(_on_item_collected)

func _on_player_died():
    get_tree().reload_current_scene()
```

### Service Locator (Autoload Singletons)

```gdscript
# GameManager.gd — added as autoload in Project Settings
extends Node

var current_level: int = 0
var player_score: int = 0
var is_paused: bool = false

signal game_started()
signal game_paused(paused: bool)
signal level_completed(level_id: int, score: int)

# Access from anywhere: GameManager.current_level
```

### When to Use Each Approach

| Pattern | Use When | Avoid When |
|---------|----------|------------|
| Direct reference (`$Path`) | Parent-child, same scene | Cross-scene communication |
| Signals | Decoupled components, event-driven flow | Simple data access |
| Autoload singleton | Global state (score, settings) | Per-instance data |
| Resource-based | Data that needs saving/loading | Runtime-only behavior |

## ECS-Like Patterns in Godot

Godot isn't a true ECS engine, but you can approximate entity-component systems:

### Entity Registry Pattern

```gdscript
class_name EntityRegistry extends Node

# Tracks all active entities by type
var _entities: Dictionary = {}

func register(entity_id: String, entity: Node) -> void:
    if not _entities.has(entity_id):
        _entities[entity_id] = []
    _entities[entity_id].append(entity)

func unregister(entity_id: String, entity: Node) -> void:
    if _entities.has(entity_id):
        _entities[entity_id].erase(entity)

func get_all(entity_id: String) -> Array:
    return _entities.get(entity_id, [])
```

### Data-Driven with Resources

```gdscript
# EntityData.tres — defines entity properties without code
class_name EntityData extends Resource

@export var entity_name: String = ""
@export var health: int = 100
@export var speed: float = 100.0
@export var components: Array[String] = []  # Component scene paths
```

## Project Structure Patterns

### Feature-Based Organization

```
res://
├── core/               # Engine-level systems (autoloads, event bus)
│   ├── GameManager.gd
│   └── EventBus.gd
├── features/           # Game features as self-contained modules
│   ├── combat/
│   │   ├── scripts/
│   │   ├── scenes/
│   │   └── resources/
│   ├── inventory/
│   │   ├── scripts/
│   │   ├── scenes/
│   │   └── resources/
│   └── dialogue/
├── levels/             # Level scenes and data
├── ui/                 # UI components and screens
└── assets/             # Art, audio, fonts
```

### Module Pattern for Large Projects

```gdscript
# FeatureModule.gd — reusable feature registration pattern
class_name FeatureModule extends Node

func initialize() -> void:
    pass  # Override in subclasses

func cleanup() -> void:
    pass  # Override in subclasses

# Usage: CombatModule.gd extends FeatureModule
# - Registers signals with EventBus
# - Spawns combat-related autoloads if needed
# - Connects to game lifecycle events
```

## Godot 4.7 Architecture Notes

- **tween_await()** — Use for sequential animations without callback chains in component scripts
- **DrawableTexture2D** — Procedural rendering for debug visualization of entity bounds
- **Perfetto tracing** — Profile architecture decisions with CPU/GPU trace markers

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools can inspect and modify your project live:

- **`scene_tree`** — Inspect scene hierarchy to audit composition patterns
- **`script_read`** / **`script_edit`** — Read and modify architecture scripts
- **`class_db_info`** — Query available methods on Godot classes for integration points

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [Composition Patterns](references/composition-patterns.md)
- [Service Locator vs Signals](references/service-locator-vs-signals.md)
- [ECS Approximation Guide](references/ecs-approximation.md)
