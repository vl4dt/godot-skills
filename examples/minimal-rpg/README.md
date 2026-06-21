# Minimal RPG Example

A minimal top-down RPG demonstrating core Godot 4.x skills patterns.

## Skills Demonstrated

| Skill | Pattern | File |
|-------|---------|------|
| [project-setup](../../skills/godot-project-setup/SKILL.md) | Project structure, input maps, collision layers | `project.godot` |
| [gdscript-patterns](../../skills/godot-gdscript-patterns/SKILL.md) | Typed signals, class_name, @export, @onready | All scripts |
| [physics](../../skills/godot-physics/SKILL.md) | CharacterBody2D movement, collision layers/masks, Area2D triggers | `scripts/player.gd`, `scripts/collectible.gd` |
| [animation](../../skills/godot-animation/SKILL.md) | AnimatedSprite2D state-driven animation | `scripts/player.gd` |
| [ui](../../skills/godot-ui/SKILL.md) | PanelContainer, VBoxContainer, signal-driven UI updates | `scripts/inventory_ui.gd` |

## How to Run

1. Open this folder in Godot 4.7+
2. Press **F5** (Run) or click the play button
3. Use **WASD** or arrow keys to move the blue square
4. Walk into colored collectible squares to pick them up
5. Watch the inventory counter update in the top-left HUD

## Project Structure

```
minimal-rpg/
├── project.godot          # Godot project config (4.7 features)
├── .gdignore              # Editor ignore patterns
├── scenes/
│   └── main.tscn          # Main scene (player, collectibles, HUD, walls)
└── scripts/
    ├── game_controller.gd  # State machine (menu/playing/paused)
    ├── player.gd           # CharacterBody2D movement + collision
    ├── collectible.gd      # Area2D pickup items
    ├── npc.gd              # NPC with patrol AI and dialogue
    └── inventory_ui.gd     # Signal-driven inventory display
```

## Key Patterns

### Typed Signals (gdscript-patterns)
```gdscript
signal item_collected(item_name: String, quantity: int)
signal npc_interacted(npc_id: String)
```

### Collision Layers (physics)
- Player: layer 1, mask layers 4 (collectibles) + 8 (walls)
- Collectibles: layer 4, mask layer 1 (player)
- Walls: StaticBody2D (no mask needed)

### State Machine (gdscript-patterns)
```gdscript
const STATES := ["idle", "moving", "interacting"] as Array[String]
var _current_state: String = "idle"
```

### Signal-Driven UI (ui)
```gdscript
player.item_collected.connect(_on_item_collected)
```

## Notes

- No external assets — uses ColorRect primitives for all visuals
- Mobile joystick support via VirtualJoystick (Godot 4.7+) in `player.gd`
- Designed to be extended: add more collectibles, NPCs, or scenes
