---
name: godot-networking
description: "Networking and multiplayer for Godot 4.x: Multiplayer API with RPC system, authority models (server-authoritative vs client-predictive), replication patterns (rpc(), rset(), rset_group()), connection management, lag compensation, and Steam Frame integration. Use when building multiplayer games, networked simulations, or online features in Godot."
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
  author: vl4dt
  version: 0.1.0
  tags:
    - godot
    - networking
    - multiplayer
    - rpc
    - replication
    - steam-frame
  created: 2026-06-20
---

# Networking and Multiplayer for Godot 4.x

Comprehensive patterns for multiplayer, RPC communication, and network synchronization in Godot 4.x.

## Multiplayer API (Godot 4.x RPC System)

### Setting Up Multiplayer

```gdscript
# In _ready(), set the peer and peer ID
func _ready():
    var peer = ENetMultiplayerPeer.new()
    peer.create_client("127.0.0.1", 9000)
    multiplayer.multiplayer_peer = peer
    multiplayer.server_id = 1  # Server is always ID 1
```

### RPC Methods

```gdscript
# Remote: Call only from non-owner
@rpc("reliable", "call_remote")
func rpc_move_player(position: Vector3):
    global_position = position

# Reliable RPC (ordered, guaranteed delivery)
@rpc("reliable", "authority", "call_remote")
func rpc_take_damage(amount: int, source_id: int):
    health -= amount
    if health <= 0:
        rpc("rpc_die", source_id)

# Unreliable RPC (faster, may drop packets — good for position updates)
@rpc("unreliable", "authority", "call_remote")
func rpc_update_position(position: Vector3, rotation: float):
    global_position = position
    rotation_degrees = rotation
```

### RPC Reliability Options

| Mode | Use Case |
|------|----------|
| `"reliable"` | Damage, state changes, game events |
| `"unreliable"` | Position updates, player movement |
| `"unreliable_ordered"` | Ordered but fast (chat messages) |
| `"call_local"` | Only on the node owner |
| `"call_remote"` | On all non-owner nodes |
| `"call_authority"` | Only on the authority node |
## Authority Models

### Server-Authoritative Model

The server has final say on all game state. Clients send inputs, server validates and broadcasts results.

```gdscript
class_name ServerAuthPlayer extends CharacterBody3D

@export var player_id: int = 0
var _server := false

func _ready():
    if multiplayer.is_server():
        _server = true
        set_multiplayer_authority(1)
    else:
        # Client-owned players are predicted locally
        set_multiplayer_authority(multiplayer.get_unique_id())

# Client sends input to server
func _input(event: InputEvent) -> void:
    if not multiplayer.is_server():
        rpc("rpc_request_move", event)

# Server receives and validates input
@rpc("authority")
func rpc_request_move(event: InputEvent):
    # Validate the input (check timing, etc.)
    _process_input(event)
```

### Client-Predictive Model

Clients predict their own actions locally and correct on server acknowledgment.

```gdscript
class_name ClientPredictivePlayer extends CharacterBody3D

@export var prediction_enabled: bool = true
var _input_buffer := []
var _last_confirmed_input: int = 0

func _physics_process(delta: float):
    # Apply buffered inputs up to current state
    for input_data in _input_buffer:
        if input_data.sequence > _last_confirmed_input:
            _apply_input(input_data)
    
    # Send position to server
    rpc("rpc_update_position", global_position, rotation_degrees)
```

### When to Use Which

| Model | Best For |
|-------|----------|
| Server-authoritative | Competitive games, anti-cheat priority |
| Client-predictive | Fast-paced action, smooth feel priority |
| Hybrid (recommended) | Most multiplayer games |
## Replication Patterns

### rpc() — Remote Procedure Call

```gdscript
# Call a method on all other nodes
rpc("rpc_on_enemy_hit", damage, target_id)

# With parameters
@rpc("reliable")
func rpc_spawn_pickup(pickup_type: String, position: Vector3):
    var pickup = preload("res://scenes/pickups/" + pickup_type + ".tscn").instantiate()
    pickup.global_position = position
    get_tree().root.add_child(pickup)
```

### rset() — Remote Set

Set a property on remote nodes.

```gdscript
# Set health bar on all clients
rset("health", new_health)
rset("max_health", max_health)
rset("visible", true)

# Bulk set with rset_group()
rset_group("players", "set_state", state_name)
```

### rset_group() — Broadcast to Group

```gdscript
# Add nodes to a group for batch updates
func _ready():
    multiplayer.add_to_group("players")

# Update all players at once
func broadcast_position():
    rset_group("players", "sync_position", global_position, rotation_degrees)

# Server-only group
func _ready():
    if multiplayer.is_server():
        add_to_group("server_only")
```

### Networked Autoload

Use autoloads for network-wide state.

```gdscript
# NetworkManager.gd (Autoload)
class_name NetworkManager extends Node

signal player_connected(player_id: int)
signal player_disconnected(player_id: int)
signal game_started()

var players := {}

func _ready():
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int):
    players[id] = PlayerInfo.new(id)
    player_connected.emit(id)

func _on_peer_disconnected(id: int):
    players.erase(id)
    player_disconnected.emit(id)
```
## Connection Management

### Server Setup

```gdscript
class_name MultiplayerServer extends Node

const PORT = 9000
const MAX_PLAYERS = 16
var server: HTTPServer

func start_server():
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(PORT, MAX_PLAYERS)
    multiplayer.multiplayer_peer = peer
    print("Server started on port ", PORT)

func stop_server():
    if multiplayer.multiplayer_peer:
        multiplayer.multiplayer_peer.disconnect_from_server()
```

### Client Connection

```gdscript
class_name MultiplayerClient extends Node

signal connected
signal connection_failed

func connect_to_server(host: String, port: int):
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(host, port)
    if error != OK:
        connection_failed.emit()
        return
    
    multiplayer.multiplayer_peer = peer
    # Wait for server to assign unique ID
    await get_tree().create_timer(0.5).timeout
    if multiplayer.is_connected_to_server():
        connected.emit()
```

### Lag Compensation

```gdscript
# Store player positions for rewind capability
class_name PositionHistory extends Node

@export var history_length: int = 3.0
var _history := []

func _physics_process(delta: float):
    _history.push_back({
        "position": global_position,
        "rotation": rotation_degrees,
        "time": Time.get_ticks_msec()
    })
    # Prune old entries
    var cutoff = Time.get_ticks_msec() - int(history_length * 1000)
    while _history.size() > 0 and _history[0].time < cutoff:
        _history.pop_front()

func get_position_at(time_ms: int) -> Variant:
    for entry in _history:
        if entry.time >= time_ms:
            return entry
    return _history.back()
```
## Steam Frame Integration (Godot 4.7+)

### Using Steam Networking Sockets

```gdscript
# Requires Steamworks SDK and godot-steam plugin
func connect_steam_server(app_id: int, steam_id: String):
    var peer = SteamMultiplayerPeer.new()
    peer.create_client(steam_id)
    multiplayer.multiplayer_peer = peer
```

### Frame-Synced Updates

For competitive games requiring frame-accurate sync:

```gdscript
@export var tick_rate: int = 60
var _tick_counter: int = 0

func _physics_process(delta: float):
    _tick_counter += 1
    if _tick_counter % (int(60 / tick_rate)) == 0:
        rpc("rpc_tick_update", _tick_counter, get_state_snapshot())
```

### Steam Lobby Integration

```gdscript
func create_lobby(max_players: int = 4):
    # Create lobby via Steamworks API
    var lobby_id = Steam.matchmaking.create_lobby(
        max_players,
        Steam.LobbyType.LobbyPrivate
    )
    return lobby_id

func join_lobby(lobby_id: String):
    Steam.matchmaking.join_lobby(lobby_id)
```
## Best Practices

### Do
- Use `@rpc("unreliable")` for frequent position updates — saves bandwidth
- Validate all client input on the server before applying
- Keep RPC payloads small — serialize only what changes
- Use `multiplayer.is_server()` guards to prevent client-side authority bugs
- Implement a heartbeat/ping system for connection quality monitoring

### Don't
- Don't call `rpc()` in `_process` without throttling — floods the network
- Don't trust client-reported health/damage — always recalculate server-side
- Don't send full state snapshots every frame — use delta compression
- Don't forget `set_multiplayer_authority()` when spawning remote nodes
- Don't mix reliable and unreliable RPCs for the same logical update

### Debugging Tips
```
# Enable network debugging in Project Settings:
  network/enable_packet_logging = true
  network/max_packet_size = 1400

# Print all RPC traffic:
multiplayer.peer_connected.connect(func(id): print("Peer connected: ", id))
multiplayer.peer_disconnected.connect(func(id): print("Peer disconnected: ", id))
```
## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools enhance networking debugging:

- **`network_peer_list`** — List connected peers and their unique IDs
- **`rpc_trace`** — Log all RPC calls with sender/receiver info for debugging
- **`network_stats`** — View bandwidth usage, packet loss, and latency metrics
- **`lobby_inspect`** — Query Steam lobby state and player list

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [Multiplayer API Documentation](references/multiplayer-api.md)
- [RPC Patterns Deep Dive](references/rpc-patterns.md)
- [Authority Models Guide](references/authority-models.md)
