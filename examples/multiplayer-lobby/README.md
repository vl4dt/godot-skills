# Multiplayer Lobby Example

A multiplayer lobby demonstrating Godot 4.x networking patterns.

## Skills Demonstrated

| Skill | Pattern | File |
|-------|---------|------|
| [project-setup](../../skills/godot-project-setup/SKILL.md) | Project structure, network config | `project.godot` |
| [networking](../../skills/godot-networking/SKILL.md) | ENetMultiplayerPeer, RPC system, authoritative server | `scripts/multiplayer_manager.gd` |
| [ui](../../skills/godot-ui/SKILL.md) | PanelContainer, VBoxContainer, signal-driven UI | `scripts/lobby_ui.gd` |
| [gdscript-patterns](../../skills/godot-gdscript-patterns/SKILL.md) | Typed signals, @rpc decorators, singleton pattern | All scripts |

## How to Run

1. Open this folder in Godot 4.7+
2. Press **F5** (Run) — click "Create Room" to host
3. In a second instance (Scene → Run Scene), click "Join Room (local)"
4. Both players click "Set Ready" to start the game

> **Note:** This demo connects locally (`127.0.0.1`). For network play, change the IP in `lobby_ui.gd`.

## Project Structure

```
multiplayer-lobby/
├── project.godot              # Godot project config (network settings)
├── .gdignore                  # Editor ignore patterns
├── scenes/
│   └── main.tscn              # Main scene (manager, lobby UI panel)
└── scripts/
    ├── multiplayer_manager.gd  # Server/client lifecycle, RPC methods, room management
    └── lobby_ui.gd             # Lobby panel with player list and controls
```

## Key Patterns

### RPC Methods (networking)
```gdscript
@rpc("any_peer", "reliable")
func register_player(player_name: String) -> void:
    var id := multiplayer.get_remote_sender_id()
    _players[id] = {"name": player_name, "ready": false}
```

### Server-Authoritative Start (networking)
```gdscript
func start_game() -> void:
    if not _is_host:
        return  # Only server can start
    game_started.emit()
```

### ENet Peer Setup (networking)
```gdscript
var peer := ENetMultiplayerPeer.new()
peer.create_server(SERVER_PORT, MAX_PLAYERS)  # Host
# or
peer.create_client(host_ip, SERVER_PORT)       # Client
```

### Signal-Driven UI (ui)
```gdscript
manager.player_joined.connect(_on_player_joined)
manager.game_started.connect(_on_game_started)
```

## Networking Architecture

This example uses Godot's built-in **high-level multiplayer API**:

1. **Host** creates an `ENetMultiplayerPeer` server
2. **Clients** connect to the host's IP/port
3. **RPCs** synchronize state (player join/ready) across peers
4. **Server authoritative** — only the host can start the game

## Notes

- Uses Godot's built-in ENet transport (no external dependencies)
- Room ID generated with random alphanumeric string
- Max 4 players configurable via `MAX_PLAYERS` constant
- Ready-up system: all players must be ready before game starts
- Steam Frame integration pattern documented in [networking skill](../../skills/godot-networking/SKILL.md)
