# MCP Bridge - WebSocket Protocol Specification

Godot Editor to MCP Server communication protocol.

## Overview

The Godot MCP server connects to a running Godot 4.x editor instance via WebSocket on localhost:6789 (configurable). The protocol uses JSON-RPC 2.0 over WebSocket frames with a simple request/response model plus push notifications.
## Connection

| Property | Value |
|----------|-------|
| Transport | WebSocket (ws://) |
| Default address | ws://127.0.0.1:6789 |
| Frame format | JSON-RPC 2.0 |
| Encoding | UTF-8 |

## Handshake

Client initiates connection with a connect request:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "connect",
  "params": {
    "clientName": "pi-agent",
    "clientVersion": "0.1.0",
    "features": ["scene", "script", "runtime", "project", "files"]
  }
}
```

Server responds:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "status": "connected",
    "godotVersion": "4.7.stable",
    "projectPath": "/path/to/project",
    "sessionId": "abc123"
  }
}
```
## Message Format

All messages follow JSON-RPC 2.0:
- id - Request correlation ID (must be unique per request)
- method - RPC method name
- params - Method parameters (object or null)
- result - Response payload (for responses only)
- error - Error object (for error responses only)

## Client to Server Methods

### Scene Operations

#### scene_tree
Get the full scene tree structure.
Params: { includeProperties: bool, includeSignals: bool, maxDepth: int }
Response: { tree: SceneNode } where SceneNode has name, type, path, children[], properties[], signals[]

#### scene_create
Create a new scene file.
Params: { path: string, rootType: string, rootName: string }
Response: { success: bool, path: string }

#### scene_add_node
Add a node to a scene.
Params: { scenePath: string, parentPath: string, nodeType: string, nodeName: string, properties: object }
Response: { success: bool, nodePath: string }

#### scene_remove_node
Remove a node from a scene.
Params: { scenePath: string, nodePath: string }
Response: { success: bool }

#### scene_move_node
Move a node in the hierarchy.
Params: { scenePath: string, nodePath: string, newParentPath: string }
Response: { success: bool, newFullPath: string }

#### scene_set_property
Set a property on a node in the scene.
Params: { scenePath: string, nodePath: string, property: string, value: any }
Response: { success: bool, oldValue: any, newValue: any }

#### scene_set_property_batch
Set multiple properties atomically.
Params: { scenePath: string, nodePath: string, properties: [{property: string, value: any}] }
Response: { success: bool, changes: [{property: string, oldValue: any, newValue: any}] }
### Script Operations

#### script_create
Create a new script file and attach to a node.
Params: { path: string, attachedTo: string, scenePath: string }
Response: { success: bool, path: string }

#### script_edit
Edit (overwrite) a script file.
Params: { path: string, content: string }
Response: { success: bool, lines: int, errors: [] }

#### script_read
Read a script file contents.
Params: { path: string }
Response: { content: string, path: string, lineCount: int }

#### script_validate
Validate a script for syntax errors.
Params: { path: string, checkDeprecated: bool, suggestTweenAwait: bool }
Response: { valid: bool, errors: [], warnings: [] }

### Project Operations

#### project_settings_read
Read project settings.
Params: { filter: string|null, keys: string[] }
Response: { settings: { [key: string]: any } }

#### project_settings_set
Set a project setting.
Params: { key: string, value: any }
Response: { success: bool, oldValue: any, newValue: any }

#### class_db_info
Query Godot class database.
Params: { className: string, includeProperties: bool, includeSignals: bool, includeMethods: bool }
Response: { className: string, inherits: [], properties: [], signals: [], methods: [] }
### Runtime Control

#### scene_run
Run the current scene in the editor.
Params: { scenePath: string }
Response: { success: bool, pid: number }

#### scene_stop
Stop the running scene.
Params: {}
Response: { success: bool }

#### debugger_output
Read current debugger output.
Params: { lines: int, sinceTimestamp: number|null }
Response: { messages: [{message: string, level: string, timestamp: number}] }

#### output_log
Read the output log.
Params: { lines: int, level: string } where level is all, error, warning, or info
Response: { messages: [{message: string, level: string, timestamp: number}] }

#### pause_resume
Pause or resume the running scene.
Params: { action: pause|resume }
Response: { success: bool, paused: bool }
### File Operations

#### file_browse
List files in a directory.
Params: { path: string, recursive: bool, includeHidden: bool }
Response: { entries: [{name: string, path: string, isDirectory: bool, size: number}] }

#### file_read
Read a file contents.
Params: { path: string }
Response: { content: string, size: number, mimeType: string }

#### file_write
Write a file contents.
Params: { path: string, content: string, append: bool }
Response: { success: bool, bytesWritten: number }

#### file_search
Search across project files.
Params: { pattern: string, scope: string, caseSensitive: bool, maxResults: int }
Response: { results: [{path: string, line: int, match: string, context: string}] }

#### file_delete
Delete a file.
Params: { path: string }
Response: { success: bool }

### Visualization

#### map_project
Generate a project structure graph.
Params: { format: json|html, includeTypes: bool, includeDependencies: bool, maxDepth: int }
Response: { graph: { nodes: [], edges: [] }, stats: { scenes: int, scripts: int, resources: int, totalFiles: int } }
## Server to Client Notifications

### scene_changed
Emitted when the editor switches scenes.
Params: { path: string, rootType: string }

### scene_saved
Emitted when a scene is saved.
Params: { path: string }

### debug_message
Emitted when a debug message is printed during runtime.
Params: { message: string, level: string, timestamp: number }

### error_occurred
Emitted when an unhandled error occurs.
Params: { message: string, file: string, line: int, timestamp: number }

### project_settings_changed
Emitted when a project setting is modified.
Params: { key: string, oldValue: any, newValue: any }
## Error Codes

| Code | Meaning |
|------|---------|
| -32700 | Parse error (invalid JSON) |
| -32600 | Invalid Request |
| -32601 | Method not found |
| -32602 | Invalid params |
| -32603 | Internal error |
| -32000 | Godot editor not responding |
| -32001 | Scene file not found |
| -32002 | Script validation failed |
| -32003 | Permission denied (read-only project) |
| -32004 | Node not found in scene |
| -32005 | Property does not exist on node type |
| -32006 | Scene is running (cannot modify) |
| -32007 | Feature not available (Godot version too old) |
## Godot 4.7 Feature-Specific Extensions

### AreaLight3D Operations
Use scene_add_node with nodeType AreaLight3D. Supports new 4.7 properties: area_mode, light_energy, light_color, normal_map.

### VirtualJoystick Configuration
Use scene_add_node with nodeType VirtualJoystick. Supports 4.7 properties: mode (relative/absolute), deadzone, snapback, touch_zone.

### HDR Output Settings
Use project_settings_set with key rendering/hdr to enable HDR output for compatible displays.

### Steam Frame Configuration
Use project_settings_set with keys under steam/frame/ for the new Steam integration overlay support.

### Android XR Settings
Use project_settings_set with key xr/openxr/enabled for extended reality development.

### tween_await() Validation
Use script_validate with suggestTweenAwait: true to detect nested tween callback patterns and suggest migration to await syntax.
## Security

- Connection is local-only (127.0.0.1) by default
- No authentication required for local connections
- The Godot editor must be running with the MCP plugin enabled
- File operations are scoped to the project directory (res://)
- Write operations require explicit confirmation from the agent

## Versioning

The protocol version is embedded in the handshake response. Clients should negotiate compatibility during handshake.

```json
{
  "status": "connected",
  "protocolVersion": "1.0.0",
  "godotVersion": "4.7.stable",
  "projectPath": "/path/to/project",
  "sessionId": "abc123"
}
```