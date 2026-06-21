# MCP Bridge (Phase 2 — Optional)

Optional MCP (Model Context Protocol) bridge for live Godot editor integration.

## Overview

The MCP bridge connects AI coding agents to a running Godot 4.x editor instance, enabling:
- Scene tree inspection and modification
- Script editing and validation
- Runtime control (run/stop scenes)
- Project settings management
- File operations within the project

## Architecture

```
AI Agent (pi/Claude/Cursor/etc.)
    │
    ▼
MCP Client (built into agent or via adapter)
    │
    ▼  stdio transport
Godot MCP Server (Node.js)
    │
    ▼  WebSocket
Godot Editor (4.7+)
```

## Tool Categories

### Scene Operations
- `create_scene` — Create a new scene file
- `add_node` — Add a node to a scene
- `remove_node` — Remove a node from a scene
- `move_node` — Move a node in the hierarchy
- `get_scene_tree` — Get the current scene tree structure
- `set_node_property` — Set a property on a node

### Script Operations
- `create_script` — Create a new script file
- `edit_script` — Modify an existing script
- `read_script` — Read script contents
- `validate_syntax` — Check script for syntax errors

### Project Operations
- `read_project_settings` — Get project configuration
- `set_project_setting` — Modify project settings
- `get_class_db_info` — Query Godot class information

### Runtime Control
- `run_scene` — Start the current scene in the editor
- `stop_scene` — Stop the running scene
- `get_debugger_output` — Read debugger output
- `get_output_log` — Read the output log

### File Operations
- `browse_directory` — List files in a directory
- `read_file` — Read file contents
- `write_file` — Write file contents
- `search_project` — Search across project files

### Visualization
- `map_project` — Generate a browser-based project graph

## Setup

### 1. Start the MCP Server
```bash
cd mcp-bridge/godot-mcp-server
npm install
node dist/index.js
```

### 2. Configure Your Agent

For pi-agent, create `mcp-bridge/pi-mcp-config/global-example.mcp.json`:
```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["/path/to/godot-mcp-server/dist/index.js"]
    }
  }
}
```

## Graceful Degradation

The Phase 1 skills work independently of the MCP bridge. If the editor is not running or the bridge is unavailable, skills fall back to static knowledge without live editor access.

## Status

Phase 2 — Design complete. Implementation pending in s7 of the WorkGraph plan.
