---
name: godot-code-review
description: "Reviews Godot projects for common pitfalls, performance issues, memory leaks, and anti-patterns. Provides a performance checklist, code style guidelines, and memory management review. Use when reviewing Godot GDScript or C# code."
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
  author: RoboCat
  version: 0.1.0
  tags:
    - godot
    - code-review
    - performance
    - anti-patterns
  created: 2026-06-20
---

# Godot Code Review

Systematic review patterns for Godot game development projects.

## Common Pitfalls & Anti-Patterns

### _process() Abuse

```gdscript
# BAD: Using _process for everything
func _process(delta):
    # Movement that could be in _physics_process
    position += velocity * delta
    # Animation updates
    update_animation()

# GOOD: Use the right callback
func _physics_process(delta):
    # Physics-related movement
    position += velocity * delta

func _process(delta):
    # Non-physics updates (UI, animations)
    update_animation()
```

### Hardcoded Paths

```gdscript
# BAD
var sprite = get_node("Character/Sprite2D")

# GOOD
@onready var sprite = $Sprite2D as Sprite2D
```

### Signal Leaks

```gdscript
# BAD: Forgetting to disconnect signals
func _ready():
    EventBus.some_signal.connect(on_some_signal)
    # If this node is freed, the callback still holds a reference

# GOOD: Auto-disconnect when using method references
func _ready():
    EventBus.some_signal.connect(on_some_signal)  # Godot auto-handles method refs

# GOOD: Manual disconnect for lambdas
func _ready():
    var callback = func(): handle_event()
    EventBus.some_signal.connect(callback)

func _exit_tree():
    EventBus.some_signal.disconnect(callback)
```

## Performance Review Checklist

### Callback Selection

| Use Case | Correct Callback | Why |
|----------|-----------------|-----|
| Physics movement | `_physics_process` | Fixed timestep, syncs with physics server |
| Non-physics updates | `_process` | Frame-rate dependent, for UI/rendering |
| One-time setup | `_ready` | Called once when node enters tree |
| Frame before ready | `_enter_tree` | Called before `_ready`, even if tree paused |
| Cleanup | `_exit_tree` | Called when node is removed from tree |
| Physics tick (input) | `_physics_input_event` | For character body input handling |

### Memory Management

- [ ] All `queue_free()` calls have corresponding signal disconnections
- [ ] No circular references between nodes
- [ ] Large resources (textures, audio) unloaded when no longer needed
- [ ] Scene instances properly freed after use
- [ ] Autoload nodes don't hold unnecessary references

### Code Style Guidelines

#### GDScript Style

- Use 4-space indentation (not tabs)
- Follow [GDScript Style Guide](https://godotengine.org/doc/en/latest/tutorials/scripting/gdscript/gdscript_styleguide.html)
- Use `@export` for inspector-exposed variables
- Use `@onready` for node paths
- Type annotations on function parameters and return values
- Use `const` for compile-time constants

#### C# Style

- Use PascalCase for class names, camelCase for members
- Use Godot's `[Export]` attributes for inspector properties
- Implement `_ExitTree()` for cleanup of event subscriptions
- Prefer structs for small value types to avoid GC pressure

### Memory Management Patterns

```gdscript
# Proper node lifecycle
func spawn_enemy():
    var enemy = enemy_scene.instantiate()
    add_child(enemy)
    # Enemy manages its own cleanup via queue_free() on death

func load_level(level_path: String):
    # Unload previous level
    if current_level:
        current_level.queue_free()
        current_level = null

    # Load new level
    var scene = load(level_path)
    current_level = scene.instantiate()
    add_child(current_level)
```

## Godot 4.7 Code Review Notes

- Check for **HDR rendering** configuration in project settings
- Review **AreaLight3D** usage for new 4.7 features (modes, intensity profiles)
- Verify **VirtualJoystick** is used instead of custom implementations on mobile
- Check that **tween_await()** replaces nested callback patterns where applicable

## Quick Review Commands

```bash
# Find all _process calls that might be physics-related
grep -rn "_process" --include="*.gd" scripts/

# Find hardcoded get_node calls (should use @onready)
grep -rn "get_node(" --include="*.gd" scripts/

# Find potential signal leaks (connect without disconnect pattern)
grep -rn "\.connect(" --include="*.gd" scripts/

# Find queue_free usage to verify cleanup
grep -rn "queue_free" --include="*.gd" scripts/
```

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools enhance code review:

- **`script_read`** — Read any script file for review without opening the editor
- **`script_validate`** — Run syntax validation with `checkDeprecated: true` and `suggestTweenAwait: true`
- **`file_search`** — Search across all project files for patterns (e.g., `queue_free`, signal leaks)
- **`file_browse`** — List project directories to verify structure
- **`class_db_info`** — Verify methods/properties exist before flagging issues

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [GDScript Style Guide](references/gdscript-styleguide.md)
- [Performance Optimization Guide](references/performance-checklist.md)
- [Memory Management Patterns](references/memory-patterns.md)
