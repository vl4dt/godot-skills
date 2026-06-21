# MCP Bridge — Tool Schemas for MCP Clients

Detailed MCP tool definitions compatible with the Model Context Protocol (MCP) specification.
Each tool is defined as an MCP-compatible tool schema that can be used by any MCP client (pi-agent, Claude Code, Cursor, Codex CLI, etc.).

## Architecture

The Godot MCP server implements the MCP stdio transport layer. Each JSON-RPC method from protocol.md is wrapped as an MCP tool with proper input schemas.



## Tool Definitions

Each tool follows the MCP tool schema format:
- name: JSON-RPC method name
- description: Human-readable tool purpose
- inputSchema: JSON Schema for parameters
- output: JSON Schema for response

## Scene Tools

### scene_tree
- Description: Get the complete scene tree structure of the current or specified scene file.
- Input Schema: { includeProperties: {type: boolean}, includeSignals: {type: boolean}, maxDepth: {type: integer, default: -1} }
- Returns: SceneNode tree with name, type, path, children[], properties[], signals[]

### scene_create
- Description: Create a new scene file with a root node of the specified type.
- Input Schema: { path: {type: string}, rootType: {type: string}, rootName: {type: string} }
- Returns: { success: bool, path: string }

### scene_add_node
- Description: Add a new node of the specified type to a scene at the given parent path.
- Input Schema: { scenePath: {type: string}, parentPath: {type: string}, nodeType: {type: string}, nodeName: {type: string}, properties: {type: object, default: {}} }
- Returns: { success: bool, nodePath: string }

### scene_remove_node
- Description: Remove a node from a scene by its path.
- Input Schema: { scenePath: {type: string}, nodePath: {type: string} }
- Returns: { success: bool }

### scene_move_node
- Description: Move a node to a new parent in the scene hierarchy.
- Input Schema: { scenePath: {type: string}, nodePath: {type: string}, newParentPath: {type: string} }
- Returns: { success: bool, newFullPath: string }

### scene_set_property
- Description: Set a single property on a node in the scene.
- Input Schema: { scenePath: {type: string}, nodePath: {type: string}, property: {type: string}, value: {type: object} }
- Returns: { success: bool, oldValue: any, newValue: any }

### scene_set_property_batch
- Description: Set multiple properties on a node atomically.
- Input Schema: { scenePath: {type: string}, nodePath: {type: string}, properties: {type: array, items: {property: string, value: object}} }
- Returns: { success: bool, changes: [{property: string, oldValue: any, newValue: any}] }

## Script Tools

### script_create
- Description: Create a new script file and optionally attach it to a node in a scene.
- Input Schema: { path: {type: string}, attachedTo: {type: string, optional: true}, scenePath: {type: string, optional: true} }
- Returns: { success: bool, path: string }

### script_edit
- Description: Overwrite the contents of a script file.
- Input Schema: { path: {type: string}, content: {type: string} }
- Returns: { success: bool, lines: int, errors: [] }

### script_read
- Description: Read the full contents of a script file.
- Input Schema: { path: {type: string} }
- Returns: { content: string, path: string, lineCount: int }

### script_validate
- Description: Validate a GDScript or C# script for syntax errors and best practices.
- Input Schema: { path: {type: string}, checkDeprecated: {type: boolean, default: false}, suggestTweenAwait: {type: boolean, default: false} }
- Returns: { valid: bool, errors: [], warnings: [] }

## Project Tools

### project_settings_read
- Description: Read one or more project settings from the current Godot project.
- Input Schema: { filter: {type: string, nullable: true}, keys: {type: array, items: {type: string}} }
- Returns: { settings: object }

### project_settings_set
- Description: Set a project setting value.
- Input Schema: { key: {type: string}, value: {type: object} }
- Returns: { success: bool, oldValue: any, newValue: any }

### class_db_info
- Description: Query the Godot class database for information about a specific class.
- Input Schema: { className: {type: string}, includeProperties: {type: boolean, default: true}, includeSignals: {type: boolean, default: true}, includeMethods: {type: boolean, default: false} }
- Returns: { className: string, inherits: [], properties: [], signals: [], methods: [] }

## Runtime Tools

### scene_run
- Description: Run the current or specified scene in the Godot editor.
- Input Schema: { scenePath: {type: string, optional: true} }
- Returns: { success: bool, pid: number }

### scene_stop
- Description: Stop the currently running scene.
- Input Schema: {}
- Returns: { success: bool }

### debugger_output
- Description: Read recent debugger output messages from the running scene.
- Input Schema: { lines: {type: integer, default: 100}, sinceTimestamp: {type: number, nullable: true} }
- Returns: { messages: [{message: string, level: string, timestamp: number}] }

### output_log
- Description: Read the Godot output log.
- Input Schema: { lines: {type: integer, default: 50}, level: {type: string, enum: [all,error,warning,info], default: all} }
- Returns: { messages: [{message: string, level: string, timestamp: number}] }

### pause_resume
- Description: Pause or resume the running scene.
- Input Schema: { action: {type: string, enum: [pause,resume]} }
- Returns: { success: bool, paused: bool }

## File Tools

### file_browse
- Description: List files and directories in a project path.
- Input Schema: { path: {type: string}, recursive: {type: boolean, default: false}, includeHidden: {type: boolean, default: false} }
- Returns: { entries: [{name: string, path: string, isDirectory: bool, size: number}] }

### file_read
- Description: Read a file from the project directory.
- Input Schema: { path: {type: string} }
- Returns: { content: string, size: number, mimeType: string }

### file_write
- Description: Write or append to a file in the project directory.
- Input Schema: { path: {type: string}, content: {type: string}, append: {type: boolean, default: false} }
- Returns: { success: bool, bytesWritten: number }

### file_search
- Description: Search for a pattern across project files.
- Input Schema: { pattern: {type: string}, scope: {type: string, default: res://}, caseSensitive: {type: boolean, default: true}, maxResults: {type: integer, default: 100} }
- Returns: { results: [{path: string, line: int, match: string, context: string}] }

### file_delete
- Description: Delete a file from the project.
- Input Schema: { path: {type: string} }
- Returns: { success: bool }

## Visualization Tools

### map_project
- Description: Generate a graph representation of the project structure showing scenes, scripts, and their dependencies.
- Input Schema: { format: {type: string, enum: [json,html], default: json}, includeTypes: {type: boolean, default: true}, includeDependencies: {type: boolean, default: true}, maxDepth: {type: integer, default: -1} }
- Returns: { graph: {nodes: [], edges: []}, stats: {scenes: int, scripts: int, resources: int, totalFiles: int} }

## Godot 4.7 Tool Extensions

The following tools leverage new Godot 4.7 features:

### AreaLight3D (scene_add_node)
- Supports new 4.7 properties: area_mode, light_energy, light_color, normal_map
- Use nodeType: AreaLight3D in scene_add_node params

### VirtualJoystick (scene_add_node)
- Supports 4.7 properties: mode (relative/absolute), deadzone, snapback, touch_zone
- Use nodeType: VirtualJoystick in scene_add_node params

### HDR Output (project_settings_set)
- Set key rendering/hdr to true/false for HDR display support

### Steam Frame (project_settings_set)
- Configure steam/frame/ settings for new Steam overlay integration

### Android XR (project_settings_set)
- Set xr/openxr/enabled for extended reality development

### tween_await() Validation (script_validate)
- Enable suggestTweenAwait: true to detect nested tween callback patterns
- Suggests migration to await syntax for cleaner code

## MCP Client Integration Examples

### pi-agent mcp.json configuration

Create mcp-bridge/pi-mcp-config/global.mcp.json:



### Claude Code MCP configuration

Add to .mcp.json in project root:



### Cursor / Windsurf MCP configuration

Add to .cursorrules or project-level settings:
- Configure MCP endpoint to point to the Godot MCP server stdio
- Tools are auto-discovered from the server manifest

## Graceful Degradation

When the Godot editor is not running or the MCP bridge is unavailable:
1. Skills fall back to static knowledge (Phase 1 skills always work)
2. MCP tool calls return error with code -32000 (Godot editor not responding)
3. Agents should handle this gracefully and continue with available knowledge
4. No feature flags needed - tools simply fail when the server cannot connect