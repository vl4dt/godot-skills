## Simple patrol enemy.
## Demonstrates: CharacterBody2D, state machine, and collision triggers.

class_name Enemy
extends CharacterBody2D

signal defeated

const GRAVITY := 980.0
const SPEED := 60.0

@export var patrol_distance: float = 100.0
@onready var sprite := $Sprite2D

var _start_position: Vector2
var _direction: int = 1


func _ready() -> void:
	_start_position = position
	collision_layer = 2  # enemy layer
	collision_mask = 3 | 4  # player + platforms


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity.x = _direction * SPEED

	# Reverse direction at patrol bounds
	var distance_from_start := abs(position.x - _start_position.x)
	if distance_from_start >= patrol_distance:
		_direction *= -1
		if sprite:
			sprite.flip_h = _direction < 0

	# Reverse on wall collision
	if is_on_wall():
		_direction *= -1
		if sprite:
			sprite.flip_h = _direction < 0

	move_and_slide()


func take_damage() -> void:
	defeated.emit()
	queue_free()
