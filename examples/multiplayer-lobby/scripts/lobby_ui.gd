## Lobby UI with player list and controls.
## Demonstrates: Container layout, signal-driven updates, VBoxContainer/HBoxContainer,
## and RPC-based state synchronization.

extends PanelContainer

@onready var create_btn := $VBox/CreateBtn
@onready var join_btn := $VBox/JoinBtn
@onready var ready_btn := $VBox/ReadyBtn
@onready var disconnect_btn := $VBox/DisconnectBtn
@onready var player_list := $VBox/PlayerList
@onready var status_label := $VBox/StatusLabel
@onready var room_id_label := $VBox/RoomIdLabel

var _is_ready: bool = false


func _ready() -> void:
	create_btn.pressed.connect(_on_create_pressed)
	join_btn.pressed.connect(_on_join_pressed)
	ready_btn.pressed.connect(_on_ready_pressed)
	disconnect_btn.pressed.connect(_on_disconnect_pressed)

	# Connect to multiplayer manager signals
	var manager := get_node_or_null("../MultiplayerManager") as MultiplayerManager
	if manager:
		manager.player_joined.connect(_on_player_joined)
		manager.player_left.connect(_on_player_left)
		manager.room_created.connect(_on_room_created)
		manager.game_started.connect(_on_game_started)
		manager.connection_status_changed.connect(_on_status_changed)

	_ready_btn_enabled(false)


func _on_create_pressed() -> void:
	var manager := get_node("../MultiplayerManager") as MultiplayerManager
	manager.create_room()
	manager.register_player.remote("Host Player")
	_create_join_buttons(false)
	_ready_btn_enabled(true)


func _on_join_pressed() -> void:
	var manager := get_node("../MultiplayerManager") as MultiplayerManager
	manager.join_room("127.0.0.1")  # Local for demo
	manager.register_player.remote("Client Player")
	_create_join_buttons(false)
	_ready_btn_enabled(true)


func _on_ready_pressed() -> void:
	var manager := get_node("../MultiplayerManager") as MultiplayerManager
	_is_ready = not _is_ready
	manager.set_ready.remote(_is_ready)
	ready_btn.text = "Ready!" if _is_ready else "Set Ready"


func _on_disconnect_pressed() -> void:
	var manager := get_node("../MultiplayerManager") as MultiplayerManager
	manager.disconnect_from_room()
	_create_join_buttons(true)
	_ready_btn_enabled(false)
	status_label.text = "Disconnected"

	# Clear player list
	for child in player_list.get_children():
		child.queue_free()


func _on_player_joined(player_id: int, player_name: String) -> void:
	var label := Label.new()
	label.text = player_name + " (ID: " + str(player_id) + ")"
	player_list.add_child(label)


func _on_player_left(player_id: int, player_name: String) -> void:
	status_label.text = player_name + " left the room"


func _on_room_created(room_id: String) -> void:
	room_id_label.text = "Room: " + room_id


func _on_game_started() -> void:
	status_label.text = "Game Starting!"
	ready_btn.visible = false


func _on_status_changed(status: String) -> void:
	status_label.text = "Status: " + status.capitalize()


func _create_join_buttons(enabled: bool) -> void:
	create_btn.visible = enabled
	join_btn.visible = enabled


func _ready_btn_enabled(enabled: bool) -> void:
	if ready_btn:
		ready_btn.disabled = not enabled
