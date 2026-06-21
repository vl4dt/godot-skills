---
name: godot-save-systems
description: "Save system patterns for Godot 4.x: resource-based saves, JSON vs binary serialization, versioning/migration strategies, cloud save integration, and corruption recovery. Use when implementing persistence in Godot games."
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
    - save-system
    - persistence
    - serialization
    - migration
  created: 2026-06-21
---

# Save Systems in Godot

Patterns for persisting game state reliably.

## Resource-Based Saves (Recommended)

Godot's `Resource` system provides native serialization with type safety:

```gdscript
class_name SaveData extends Resource

const SAVE_VERSION := 1

@export var save_version: int = SAVE_VERSION
@export var timestamp: float = 0.0
@export var player_position: Vector2 = Vector2.ZERO
@export var player_health: int = 100
@export var inventory: Array[Resource] = []
@export var quest_flags: Dictionary = {}
```

### Save Manager

```gdscript
class_name SaveManager extends Node

const SAVE_PATH := "user://savegame.tres"

func save(data: SaveData) -> Error:
    data.timestamp = Time.get_unix_time_from_system()
    var error = ResourceSaver.save(data, SAVE_PATH)
    if error != Error.OK:
        push_error("SaveManager: Failed to save — %d" % error)
    return error

func load() -> SaveData:
    if not FileAccess.file_exists(SAVE_PATH):
        return null
    var data = ResourceLoader.load(SAVE_PATH) as SaveData
    if not data:
        push_error("SaveManager: Failed to load save file")
        return null
    return data

func delete() -> void:
    DirAccess.remove_absolute(SAVE_PATH)

func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)
```

### Multiple Save Slots

```gdscript
func get_slot_path(slot_index: int) -> String:
    return "user://savegame_%d.tres" % slot_index

# Save slot metadata for UI display
class_name SlotInfo extends Resource
    @export var slot_index: int = 0
    @export var timestamp: float = 0.0
    @export var player_level: int = 1
    @export var thumbnail: Texture2D = null
```

## JSON Serialization

For human-readable saves or cross-platform data exchange:

```gdscript
func save_as_json(data: SaveData, path: String) -> Error:
    var dict := {
        "version": data.save_version,
        "timestamp": data.timestamp,
        "position": { "x": data.player_position.x, "y": data.player_position.y },
        "health": data.player_health,
        "inventory": [],
        "quests": data.quest_flags
    }
    var json = JSON.stringify(dict)
    var file = FileAccess.open(path, FileAccess.WRITE)
    if not file:
        return Error.CANT_OPEN
    file.store_string(json)
    return Error.OK

func load_from_json(path: String) -> SaveData:
    var file = FileAccess.open(path, FileAccess.READ)
    if not file:
        return null
    var json_str = file.get_as_text()
    var parse_result = JSON.parse_string(json_str)
    if parse_result is Dictionary:
        return _dict_to_save_data(parse_result as Dictionary)
    return null
```

## Versioning and Migration

Handle save format changes across game updates:

```gdscript
func load() -> SaveData:
    var raw = ResourceLoader.load(SAVE_PATH) as SaveData
    if not raw:
        return null

    # Migrate older save formats to current version
    while raw.save_version < SaveData.SAVE_VERSION:
        raw = _migrate(raw, raw.save_version)

    return raw

func _migrate(data: SaveData, from_version: int) -> SaveData:
    match from_version:
        0:
            # v0 → v1: add quest_flags field
            data.quest_flags = {}
            data.save_version = 1
        _:
            push_warning("SaveManager: Unknown migration from v%d" % from_version)
    return data
```

## Corruption Recovery

Protect against corrupted save files:

```gdscript
func load_safe() -> SaveData:
    var data = load()
    if data and _validate(data):
        return data

    # Try backup
    if FileAccess.file_exists(SAVE_PATH + ".bak"):
        push_warning("SaveManager: Primary save corrupted, loading backup")
        var temp = SAVE_PATH
        OS.move_to_trash(SAVE_PATH)  # Move corrupted file
        DirAccess.copy_absolute(SAVE_PATH + ".bak", SAVE_PATH)
        return load()

    push_error("SaveManager: No valid save found")
    return null

func _validate(data: SaveData) -> bool:
    if not data:
        return false
    if data.save_version < 1:
        return false
    # Add more validation checks
    return true

# Create backup on successful save
func save_with_backup(data: SaveData) -> Error:
    # Backup current save
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.copy_absolute(SAVE_PATH, SAVE_PATH + ".bak")
    return save(data)
```

## Cloud Save Integration Pattern

Abstract cloud provider behind an interface:

```gdot
class_name CloudSaveProvider extends RefCounted

virtual func upload(data: String, key: String) -> bool:
    return false

virtual func download(key: String) -> String:
    return ""

virtual func delete(key: String) -> bool:
    return false

# Usage: implement concrete providers
# class_name GooglePlaySaveProvider extends CloudSaveProvider
# class_name AppleCloudSaveProvider extends CloudSaveProvider
```

## Auto-Save Strategies

```gdscript
class_name AutoSaver extends Node

@export var interval_seconds: float = 30.0
var _timer: Timer
var _save_manager: SaveManager

func _ready() -> void:
    _timer = Timer.new()
    _timer.wait_time = interval_seconds
    _timer.timeout.connect(_on_auto_save)
    add_child(_timer)
    _timer.start()

func _on_auto_save() -> void:
    var data = _build_save_data()
    _save_manager.save(data)
```

## Godot 4.7 Save Notes

- **ResourceSaver** supports `ResourceSaver.FLAG_COMPRESS` for smaller save files
- **ConfigFile** — Use for settings/preferences (separate from game saves)

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools can inspect and modify your project live:

- **`script_read`** / **`script_edit`** — Read and modify save system scripts
- **`project_info`** — Check user:// directory paths for save location debugging

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [Resource Save Patterns](references/resource-saves.md)
- [Save Migration Strategies](references/save-migration.md)
- [Cloud Save Integration](references/cloud-saves.md)
