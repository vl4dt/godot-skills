---
name: godot-project-setup
description: "Scaffolds a new Godot 4.x project with proper folder structure, .gdignore, export presets, .gitignore, and GDScript/C# Mono initialization. Use when creating a new Godot game or app."
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
    - project-setup
    - scaffolding
    - export-presets
  created: 2026-06-20
---

# Godot Project Setup

Scaffold a complete, production-ready Godot 4.x project with industry-standard organization.

## Quick Start

```bash
# Create a new project
./scripts/new-godot-project.sh MyGame /path/to/output
```

## Standard Directory Structure

After scaffolding, your project will have:

```
MyGame/
├── .gdignore              # Exclude editor cache from export
├── .gitignore             # Version control ignores
├── project.godot          # Project configuration
├── scenes/                # Scene files (.tscn)
│   ├── ui/               # UI scene compositions
│   ├── levels/           # Level/world scenes
│   └── entities/         # Character/entity scenes
├── scripts/               # Script files (.gd, .cs)
│   ├── core/             # Game systems (manager, event bus)
│   ├── entities/         # Entity behaviors
│   ├── ui/               # UI controllers
│   └── levels/           # Level-specific logic
├── resources/             # Resource files (.tres, .res)
│   ├── data/             # Game data (items, skills, etc.)
│   └── config/           # Configuration resources
├── assets/               # Raw assets (do not edit in Godot)
│   ├── textures/
│   ├── audio/
│   ├── fonts/
│   └── models/
├── levels/               # Level data and configurations
└── export_presets.cfg    # Export presets (auto-generated)
```

## Project.godot Configuration

Key settings for a clean project:

```ini
[application]

config/icon="res://assets/icons/icon.png"

[display]

window/size/width=1280
window/size/height=720
window/stretch/mode="canvas_items"

[rendering]

renderer/rendering_method="forward_plus"
```

## .gdignore Setup

Create `.gdignore` in directories that Godot should not import:

```
# In assets/ directory
# Godot ignores this directory for resource imports
```

## GDScript Project Initialization

Standard project.godot autoload setup:

```gdscript
# Add to Project Settings > Autoload
# Name: GameManager, Path: res://scripts/core/game_manager.gd
# Name: EventBus, Path: res://scripts/core/event_bus.gd
# Name: AudioManager, Path: res://scripts/core/audio_manager.gd
```

## C# Mono Project Initialization

For C# projects, the scaffolded project includes:

- `.csproj` file configured for Godot 4.x
- `global.json` for .NET version pinning
- Standard namespace structure matching directory layout
- `[Export]` attribute patterns in template scripts

## Godot 4.7 Specific Setup

When creating projects with Godot 4.7 features:

1. **HDR Settings** — Enable in project.godot:
   ```ini
   [rendering]
   environment/default_environment="default_world.tres"
   ```

2. **Steam Frame Configuration** — Add to project.godot:
   ```ini
   [steam]
   app_id="YOUR_APP_ID"
   ```

3. **VirtualJoystick** — Use built-in node for mobile projects instead of third-party solutions

4. **Export Presets** — Configure for:
   - Windows Desktop (64-bit)
   - Linux/X11 (64-bit)
   - Android (API 31+)
   - HTML5 (Web)

## Export Presets

Common export configurations:

| Target | Settings | Notes |
|--------|----------|-------|
| Windows | Desktop, 64-bit, D3D12 | Default for PC games |
| Linux | Desktop, 64-bit, Vulkan | Requires vulkan drivers |
| Android | Mobile, API 31+, ARM64 | Use VirtualJoystick for controls |
| HTML5 | Web, WASM | Limited to web-compatible features |

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools can inspect and modify your project live:

- **`project_settings_read`** — Read current project.godot settings
- **`project_settings_set`** — Modify project settings (e.g., enable HDR, set Steam app ID)
- **`file_browse`** — List project directories to verify scaffold structure
- **`file_write`** — Write configuration files directly
- **`class_db_info`** — Query Godot class database for export preset node types

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [Godot Project Configuration](references/project-configuration.md)
- [Export Presets Deep Dive](references/export-presets.md)
- [Mono/C# Setup Guide](references/mono-setup.md)
