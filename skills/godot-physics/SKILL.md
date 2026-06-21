---
name: godot-physics
description: Physics systems for Godot 4.x: collision layers/masks, rigid body dynamics, character controllers (CharacterBody2D/3D), area nodes for triggers, physics interpolation, bulk queries, and performance optimization. Use when implementing physics, collisions, movement, or triggers in Godot.
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
    - physics
    - collision
    - character-body
    - rigid-body
    - area
  created: 2026-06-20
---

# Physics Systems for Godot 4.x

Comprehensive patterns for physics, collisions, and movement in Godot 4.x.

## Collision Layers and Masks (Godot 4.x Typed System)

Godot 4.x uses bit-based collision layer/mask system for efficient spatial queries.

### Configuring Collision Layers

Set layers in the editor via Inspector > CollisionShape3D > Collision Layer (bits 1-32).

```gdscript
# Recommended layer layout
const LAYER_PLAYER = 0x1
const LAYER_ENEMIES = 0x2
const LAYER_PROJECTILES = 0x4
const LAYER_ENVIRONMENT = 0x8
const LAYER_PICKUPS = 0x10
const LAYER_TRIGGERS = 0x20

collision_layer = LAYER_PLAYER
collision_mask = LAYER_ENVIRONMENT | LAYER_PICKUPS
```

### Layer Design Best Practices

| Layer | Bit | Use Case |
|-------|-----|----------|
| 1 | `0x1` | Player characters |
| 2 | `0x2` | Enemies and NPCs |
| 4 | `0x4` | Projectiles and weapons |
| 8 | `0x8` | Environment / terrain |
| 16 | `0x10` | Pickups and collectibles |
| 32 | `0x20` | Triggers (Area-only) |

### Typed Collision Queries

```gdscript
var ray_query := PhysicsRayQueryParameters3D.new()
ray_query.from = camera.global_position
ray_query.to = global_position + forward * range
ray_query.collision_mask = LAYER_ENVIRONMENT
ray_query.exclude = [self]

var result = get_world_3d().direct_space.intersect_ray(ray_query)
if result:
    var collider = result.get("collider")
    print("Hit: ", collider.get_name())
```

## Rigid Body Dynamics

### Basic Rigid Body Setup

```gdscript
class_name PlayerRigidBody extends CharacterBody3D

@export var gravity_scale: float = 1.0
@export var jump_force: float = 8.0
@export var move_speed: float = 5.0

var velocity := Vector3.ZERO

func _physics_process(delta: float) -> void:
    velocity.y -= 9.8 * gravity_scale * delta
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity.x = input_dir.x * move_speed
    velocity.z = input_dir.y * move_speed
    move_and_slide()
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = jump_force
```

### Physics Material

```gdscript
var bouncy_material := PhysicsMaterial.new()
bouncy_material.bounce = 0.8
bouncy_material.friction = 0.2
collision_shape.shape.material = bouncy_material
```

### Rigid Body with Forces

```gdscript
class_name Projectile extends RigidBody3D

@export var lifetime: float = 3.0
@export var damage: int = 10

func _ready() -> void:
    linear_velocity = transform.basis.z * 20.0
    get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _on_body_entered(body: Node3D) -> void:
    if body is Enemy:
        body.take_damage(damage)
        queue_free()
```

## Character Controllers

### CharacterBody3D Movement Pattern

```gdscript
class_name ThirdPersonController extends CharacterBody3D

@export var walk_speed: float = 4.0
@export var run_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var gravity_amount: float = 9.8
@export var sprint_factor: float = 2.0

var _is_sprinting := false

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity_amount * delta
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity
    var input_dir := Vector2.ZERO
    input_dir = Vector2(
        Input.get_axis("move_left", "move_right"),
        Input.get_axis("move_up", "move_down")
    )
    _is_sprinting = Input.is_action_pressed("sprint")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        var spd = run_speed * sprint_factor if _is_sprinting else walk_speed
        velocity.x = direction.x * spd
        velocity.z = direction.z * spd
    else:
        velocity.x = move_toward(velocity.x, 0, walk_speed)
        velocity.z = move_toward(velocity.z, 0, walk_speed)
    move_and_slide()
```

### CharacterBody2D Platformer Pattern

```gdscript
class_name PlatformerCharacter extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = -450.0
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 700.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta
        velocity.y = min(velocity.y, max_fall_speed)
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = jump_force
    var move_input := Input.get_axis("move_left", "move_right")
    if move_input:
        velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, friction * delta)
    move_and_slide()
```

## Area Nodes for Triggers and Detection

### Basic Pickup Zone

```gdscript
class_name PickupZone extends Area3D

@export var pickup_scene: PackedScene
@export var min_items: int = 1
@export var max_items: int = 3
var _has_been_activated := false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
    if _has_been_activated: return
    if body is CharacterBody3D:
        _spawn_items()
        _has_been_activated = true
        queue_free()

func _spawn_items() -> void:
    var count = randi() % (max_items - min_items + 1) + min_items
    for i in range(count):
        var item = pickup_scene.instantiate()
        item.position = global_position + Vector3(randf() * 2 - 1, 0.5, randf() * 2 - 1)
        get_tree().root.add_child(item)
```

### Enemy Detection Sensor

```gdscript
class_name EnemySensor extends Area3D

signal player_detected(player: CharacterBody3D)
signal player_lost(player: CharacterBody3D)

@export var detection_radius: float = 10.0
@export var detection_layers: int = 0x1

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    var sphere := SphereShape3D.new()
    sphere.radius = detection_radius
    $CollisionShape3D.shape = sphere
    collision_mask = detection_layers

func _on_body_entered(body: Node3D) -> void:
    if body is CharacterBody3D:
        player_detected.emit(body)

func _on_body_exited(body: Node3D) -> void:
    if body is CharacterBody3D:
        player_lost.emit(body)
```

## Physics Interpolation (Godot 4.x Feature)

Godot 4.x supports physics interpolation for smooth rendering between physics ticks.

### Enabling Physics Interpolation

Enable in Project Settings > Rendering > Other > Physics Interpolation set to "Interpolate". The engine automatically interpolates transforms between physics ticks when rendering. No extra code needed for standard nodes.

For custom rendering, use the built-in interpolation factor available through the rendering pipeline.

## Performance: Bulk Physics Queries

### Space State Batched Queries

```gdscript
func get_all_collisions_in_area(origin: Vector3, radius: float, mask: int) -> Array:
    var query := PhysicsShapeQueryParameters3D.new()
    var sphere := SphereShape3D.new()
    sphere.radius = radius
    query.shape = sphere
    query.transform = Transform3D.IDENTITY.translated(origin)
    query.collision_mask = mask
    query.exclude = [self]
    var space = get_world_3d().direct_space
    return space.intersect_shape(query)

func aoe_attack(center: Vector3, radius: float, damage: int) -> void:
    var hits := get_all_collisions_in_area(center, radius, LAYER_ENEMIES | LAYER_PROJECTILES)
    for hit in hits:
        var collider = hit.get("collider")
        if collider is Enemy:
            collider.take_damage(damage)
```

### Collision Layer Optimization

- Only check layers you need — avoid `collision_mask = 0xFFFFFFFF`
- Use `NavigationServer3D` for pathfinding queries
- Use small-radius `Area3D` nodes for proximity checks
- Avoid querying the entire world every frame

## Godot 4.7 Physics Notes

- Physics interpolation is more robust with improved accuracy
- Use `AreaLight3D` for dynamic light casting on visible surfaces
- Test physics performance with Perfetto tracing on mobile targets

## Quick Reference: Movement Methods

| Method | Use Case | Returns |
|--------|----------|---------|
| `move_and_slide()` | Standard character movement | SlideFlags |
| `move_and_collide()` | When you need collision info | CollisionData or null |
| `move_and_snap()` | Platformer with snap-to-floor | SlideFlags |
| `move_teleport()` | Teleportation (no sliding) | CollisionData or null |

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools enhance physics debugging:

- **`physics_debug_draw`** — Toggle collision shape visualization in editor
- **`physics_query_shape`** — Run shape queries from any position without placing nodes
- **`rigid_body_apply_force`** — Apply forces to rigid bodies for testing
- **`physics_stats`** — View active physics bodies, sleep count, and frame cost

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [CharacterBody3D Documentation](references/characterbody3d-guide.md)
- [Collision Layer Design Patterns](references/collision-layers.md)
- [Physics Material Reference](references/physics-materials.md)