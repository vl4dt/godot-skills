## Non-player character with dialogue.
## Demonstrates: Resource-based NPC data, state machine, and typed signals.

class_name NPC
extends CharacterBody2D

signal dialogue_started(npc_id: String, text: String)

const SPEED := 40.0
const PATROL_RADIUS := 60.0

@export var npc_id: String = "merchant"
@export var dialogue_text: String = "Hello, adventurer!"
@export var patrol_points: Array[Vector2] = []

var _current_point_index: int = 0
var _state: String = "patrol"


func _ready() -> void:
	collision_layer = 2  # npc layer
	collision_mask = 1  # detect player


func get_npc_id() -> String:
	return npc_id


func _physics_process(delta: float) -> void:
	match _state:
		"patrol":
			_patrol(delta)
		"idle":
			pass


func _patrol(delta: float) -> void:
	if patrol_points.is_empty():
		return

	var target := patrol_points[_current_point_index]
	var direction := (target - global_position).normalized()
	var distance := global_position.distance_to(target)

	if distance < 5.0:
		_current_point_index = (_current_point_index + 1) % patrol_points.size()
	else:
		velocity = direction * SPEED
		move_and_slide()


func start_dialogue() -> void:
	_state = "idle"
	velocity = Vector2.ZERO
	dialogue_started.emit(npc_id, dialogue_text)
