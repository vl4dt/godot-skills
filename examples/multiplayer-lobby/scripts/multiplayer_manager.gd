## Multiplayer session manager.
## Demonstrates: Godot's built-in multiplayer API, authoritative server model,
## RPC patterns (rpc, rset, rset_group), and connection lifecycle.

class_name MultiplayerManager
extends Node

# Signals for UI updates
signal player_joined(player_id: int, player_name: String)
signal player_left(player_id: int, player_name: String)
signal room_created(room_id: String)
signal game_started
signal connection_status_changed(status: String)

const MAX_PLAYERS := 4
const SERVER_PORT := 8080

var _is_host: bool = false
var _players: Dictionary = {}  # id -> {name, ready}
var _room_id: String = ""


func create_room() -> void:
	"""Create a new room as the host/server."""
	_is_host = true
	_room_id = _generate_room_id()

	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(SERVER_PORT, MAX_PLAYERS)

	if err != OK:
		push_error("Failed to create server: " + str(err))
		return

	multiplayer.multiplayer_peer = peer
	players_changed.connect(_on_players_changed)
	connection_status_changed.emit("host")
	room_created.emit(_room_id)

	# Register self as player 1
	_players[1] = {"name": "Host", "ready": false}
	player_joined.emit(1, "Host")


func join_room(host_ip: String) -> void:
	"""Join an existing room as a client."""
	_is_host = false

	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(host_ip, SERVER_PORT)

	if err != OK:
		push_error("Failed to connect: " + str(err))
		return

	multiplayer.multiplayer_peer = peer
	players_changed.connect(_on_players_changed)
	connection_status_changed.emit("connected")


func disconnect_from_room() -> void:
	"""Disconnect from the current room."""
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	_is_host = false
	_players.clear()
	connection_status_changed.emit("disconnected")


@rpc("any_peer", "reliable")
func register_player(player_name: String) -> void:
	"""Register a player's name (called by all peers on join)."""
	var id := multiplayer.get_remote_sender_id()
	if id > 0 and _players.size() < MAX_PLAYERS:
		_players[id] = {"name": player_name, "ready": false}
		player_joined.emit(id, player_name)


@rpc("any_peer", "reliable")
func set_ready(is_ready: bool) -> void:
	"""Set a player's ready state."""
	var id := multiplayer.get_remote_sender_id()
	if id > 0 and _players.has(id):
		_players[id]["ready"] = is_ready

	# Check if all players are ready (server only)
	if _is_host and _all_ready():
		start_game()


func start_game() -> void:
	"""Start the game when all players are ready (server authoritative)."""
	if not _is_host:
		return
	game_started.emit()


func get_room_id() -> String:
	return _room_id


func get_player_count() -> int:
	return _players.size()


func is_host() -> bool:
	return _is_host


func _on_players_changed() -> void:
	# Emitted when players array changes
	pass


func _all_ready() -> bool:
	for player_data in _players.values():
		if not player_data["ready"]:
			return false
	return true


func _generate_room_id() -> String:
	var chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var id := ""
	for i in range(6):
		id += chars[randi() % chars.length()]
	return id


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		disconnect_from_room()
