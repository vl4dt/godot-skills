## Platformer player controller.
## Demonstrates: CharacterBody2D movement, gravity, jumping, input buffering,
## and VirtualJoystick support (Godot 4.7+).

class_name Player
extends CharacterBody2D

signal died
signal level_complete

const GRAVITY := 980.0
const MOVE_SPEED := 200.0
const JUMP_VELOCITY := -350.0
const INPUT_BUFFER_FRAMES := 6
const COYOTE_FRAMES := 6

@export var jump_buffer_frames: int = INPUT_BUFFER_FRAMES
@onready var sprite := $Sprite2D
@onready var animated_sprite := $AnimatedSprite2D

var _input_buffer_timer: int = 0
var _coyote_timer: int = 0
var _was_on_floor: bool = true


func _ready() -> void:
	# Player collides with platforms and enemies
	collision_layer = 1  # player layer
	collision_mask = 4 | 2 | 8  # platforms + enemies + hazards


func _physics_process(delta: float) -> void:
	var direction := _get_input_direction()

	# Horizontal movement
	velocity.x = direction * MOVE_SPEED
	velocity.y += GRAVITY * delta

	# Coyote time tracking
	if is_on_floor():
		_coyote_timer = COYOTE_FRAMES
		_was_on_floor = true
	else:
		_coyote_timer -= 1 if _coyote_timer > 0 else 0

	# Input buffer for jump
	if Input.is_action_just_pressed("jump"):
		_input_buffer_timer = jump_buffer_frames

	if _input_buffer_timer > 0:
		_input_buffer_timer -= 1

	# Jump with coyote time + input buffering
	if _input_buffer_timer > 0 and (_was_on_floor or _coyote_timer > 0):
		velocity.y = JUMP_VELOCITY
		_input_buffer_timer = 0
		_coyote_timer = 0
		_was_on_floor = false

	move_and_slide()

	# Update facing direction
	if sprite and direction != 0:
		sprite.flip_h = direction < 0


func _get_input_direction() -> float:
	var dir := Input.get_axis("move_left", "move_right")

	# VirtualJoystick support (Godot 4.7+)
	if _joystick_active():
		dir = Input.get_axis("ui_left", "ui_right")

	return dir


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		# Check if landing on top of enemy (stomp)
		if velocity.y > 0 and position.y < body.position.y:
			body.take_damage()
			velocity.y = JUMP_VELOCITY * 0.7  # Bounce
		else:
			die()
	elif body.get_collision_layer_value(4):  # Hazard layer
		die()


func die() -> void:
	died.emit()
	queue_free()


func _joystick_active() -> bool:
	return Input.get_connected_joypads().size() > 0
