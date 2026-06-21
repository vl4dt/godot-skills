## Game controller that manages scene state and global game logic.
## Demonstrates: State machine pattern, event bus, and scene management.

extends Node

signal game_started
signal game_paused
signal game_resumed

const STATES := ["menu", "playing", "paused"] as Array[String]
var _current_state: String = "menu"


func _ready() -> void:
	# Wait for input to start game
	await get_tree().create_timer(0.5).timeout
	_set_state("playing")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _current_state == "menu":
			_set_state("playing")
		elif _current_state == "playing":
			_set_state("paused")
		elif _current_state == "paused":
			_set_state("playing")


func _set_state(new_state: String) -> void:
	if not new_state in STATES:
		push_error("Invalid game state: " + new_state)
		return

	_current_state = new_state
	match new_state:
		"playing":
			game_started.emit()
			get_tree().paused = false
		"paused":
			game_paused.emit()
			get_tree().paused = true
		"menu":
			get_tree().paused = false
