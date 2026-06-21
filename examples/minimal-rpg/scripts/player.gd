## Player controller for the minimal RPG example.
## Demonstrates: CharacterBody2D movement, collision layers, state machine pattern,
## typed signals, and VirtualJoystick support (Godot 4.7+).

class_name Player
extends CharacterBody2D

signal item_collected(item_name: String, quantity: int)
signal npc_interacted(npc_id: String)

const SPEED := 160.0
const STATES := ["idle", "moving", "interacting"] as Array[String]

@export var speed_multiplier: float = 1.0
@onready var sprite := $Sprite2D
@onready var animated_sprite := $AnimatedSprite2D
@onready var collision_shape := $CollisionShape2D

var _current_state: String = "idle"
var _facing_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = 16.0
	# Player collides with walls and collectibles
	collision_layer = 1  # player layer
	collision_mask = 8 | 4  # walls + collectibles


func _physics_process(delta: float) -> void:
	var input_dir := _get_input_direction()

	if input_dir != Vector2.ZERO:
		_facing_direction = input_dir
		_set_state("moving")
	else:
		_set_state("idle")

	var velocity := input_dir * SPEED * speed_multiplier
	move_and_slide()

	# Update animation direction
	if animated_sprite and _current_state == "moving":
		_update_animation(input_dir)


func _get_input_direction() -> Vector2:
	# Keyboard input (move_up, move_down, move_left, move_right)
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# VirtualJoystick overlay (Godot 4.7+) — check for active joystick
	if _joystick_active():
		dir = _get_joystick_direction()

	return dir


func _set_state(new_state: String) -> void:
	if new_state in STATES:
		_current_state = new_state
		if animated_sprite:
			animated_sprite.play(_current_state)


func _update_animation(direction: Vector2) -> void:
	if not animated_sprite:
		return
	var frame := 0
	if direction.y < 0:
		frame = 0  # up
	elif direction.y > 0:
		frame = 2  # down
	elif direction.x < 0:
		frame = 1  # left
	elif direction.x > 0:
		frame = 3  # right
	animated_sprite.frame = frame


func _on_body_entered(body: Node2D) -> void:
	if body is Collectible:
		var collectible := body as Collectible
		item_collected.emit(collectible.item_name, collectible.quantity)
		collectible.queue_free()
	elif body.has_method("get_npc_id"):
		npc_interacted.emit(body.get_npc_id())


func _joystick_active() -> bool:
	# Check for active VirtualJoystick (Godot 4.7+)
	return Input.get_connected_joypads().size() > 0


func _get_joystick_direction() -> Vector2:
	var deadzone := 0.2
	var x := Input.get_axis("ui_left", "ui_right")
	var y := Input.get_axis("ui_up", "ui_down")
	var dir := Vector2(x, y)
	if dir.length() < deadzone:
		return Vector2.ZERO
	return dir.normalized()
