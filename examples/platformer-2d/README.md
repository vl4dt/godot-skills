# Platformer 2D Example

A minimal side-scrolling platformer demonstrating Godot 4.x skills patterns.

## Skills Demonstrated

| Skill | Pattern | File |
|-------|---------|------|
| [project-setup](../../skills/godot-project-setup/SKILL.md) | Project structure, input maps, collision layers | `project.godot` |
| [gdscript-patterns](../../skills/godot-gdscript-patterns/SKILL.md) | Typed signals, class_name, @export, const patterns | All scripts |
| [physics](../../skills/godot-physics/SKILL.md) | CharacterBody2D gravity/jumping, StaticBody2D platforms, body_entered | `scripts/player.gd`, `scripts/enemy.gd` |
| [animation](../../skills/godot-animation/SKILL.md) | Sprite flip direction, tween-based camera smoothing | `scripts/camera.gd` |
| [input](../../skills/godot-input/SKILL.md) | Input buffering, coyote time, VirtualJoystick (4.7+) | `scripts/player.gd` |

## How to Run

1. Open this folder in Godot 4.7+
2. Press **F5** (Run) or click the play button
3. Use **WASD/Arrows** to move, **W/Space** to jump
4. Land on enemies from above to defeat them (stomp mechanic)
5. Avoid red hazard zones at the bottom

## Project Structure

```
platformer-2d/
├── project.godot          # Godot project config (4.7 features)
├── .gdignore              # Editor ignore patterns
├── scenes/
│   └── main.tscn          # Main scene (player, platforms, enemy, hazards, HUD)
└── scripts/
    ├── player.gd           # CharacterBody2D with gravity, jump buffering, coyote time
    ├── enemy.gd            # Patrol AI with direction reversal
    ├── camera.gd           # Smooth follow camera with lerpf
    └── hud.gd              # Score/lives display with tween messages
```

## Key Patterns

### Input Buffering + Coyote Time (input)
```gdscript
# Allow jump input slightly before landing (buffer frames)
if _input_buffer_timer > 0 and (_was_on_floor or _coyote_timer > 0):
    velocity.y = JUMP_VELOCITY
```

### Gravity + Jumping (physics)
```gdscript
velocity.y += GRAVITY * delta
move_and_slide()
```

### Stomp Detection (physics)
```gdscript
if body is Enemy:
    if velocity.y > 0 and position.y < body.position.y:
        body.take_damage()  # Landing on top
    else:
        die()  # Touching from side/bottom
```

### Smooth Camera (animation)
```gdscript
position.x = lerpf(position.x, target.position.x, smoothing)
```

## Notes

- No external assets — uses ColorRect primitives for all visuals
- VirtualJoystick support (Godot 4.7+) in `player.gd`
- Enemy patrol reverses on wall collision and distance bounds
- Tween-based message fade in HUD
