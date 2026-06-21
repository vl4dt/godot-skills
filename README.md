# @vl4dt/godot-skills

**Godot game development skills for AI coding agents.**

A complete, distributable, open-source skill package providing domain knowledge, best practices, and patterns for Godot 4.x game development with full Godot 4.7 feature coverage. Compatible with pi-agent and 30+ other coding agents via the [Agent Skills Open Standard](https://agentskills.io).

## Quick Start

### Install in pi-agent
```bash
pi install npm:@vl4dt/godot-skills
```

### Install from GitHub
```bash
pi install git:github.com/vl4dt/godot-skills@v0.1.0
```

### Local development
```bash
cd /path/to/your-project
pi install ./path/to/godot-skills -l
```

## Available Skills

| Skill | Description |
|-------|-------------|
| **godot-project-setup** | Scaffold a new Godot 4.x project with proper folder structure, .gdignore, export presets, and GDScript/C# initialization |
| **godot-brainstorming** | Architecture decision patterns for different game genres, scene organization strategies, state machines, network architecture |
| **godot-gdscript-patterns** | GDScript best practices: node composition, typed signals, scene instantiation, resource management, singletons, event buses |
| **godot-csharp-patterns** | C# Mono patterns: Export attributes, signal handling, performance optimization, GDExtension interop |
| **godot-code-review** | Common pitfalls, performance checklist, code style guidelines, memory management, signal leak detection |
| **godot-debugging** | Debugging workflow, common error patterns, profiling, network debugging, export/build troubleshooting |
| **godot-47-migration** | Step-by-step migration from Godot 4.x to 4.7: HDR, Steam Frame, AreaLight3D, VirtualJoystick, tween_await(), Perfetto tracing |
| **godot-physics** | Physics systems: collision layers/masks, rigid body dynamics, character controllers (CharacterBody2D/3D), area triggers, physics interpolation |
| **godot-animation** | Animation systems: AnimationPlayer vs AnimationTree, state machines, blend spaces (1D/2D/directional), root motion, tween_await() |
| **godot-ui** | UI systems: Control hierarchy, containers and layout modes, themes, RichTextLabel, PopupMenu search, control offset transforms (4.7) |
| **godot-performance** | Performance optimization: profiling workflow, memory management, instancing/LOD, draw calls, mobile optimization, Perfetto tracing |
| **godot-networking** | Networking and multiplayer: RPC system, authority models, replication patterns (rpc/rset/rset_group), lag compensation, Steam Frame |

## Godot 4.7 Feature Coverage

All skills include up-to-date coverage of Godot 4.7 features:

- HDR output settings and configuration
- Steam Frame integration
- New AreaLight3D node support
- VirtualJoystick for mobile development
- `tween_await()` for animation sequences
- Collapsible animation tracks
- PopupMenu search functionality
- Control offset transforms for UI animation
- Perfetto tracing for Android profiling
- Nearest-neighbor viewport scaling
- DrawableTexture2D for dynamic textures

## MCP Bridge (Phase 2 — Optional)

The MCP bridge provides live Godot editor integration via the Model Context Protocol. When enabled, skills can query the running editor for scene trees, run scenes, inspect debugger output, and modify project settings in real time.

### Architecture

```
AI Agent (pi/Claude/Cursor/etc.)
    │
    ▼
MCP Client (built into agent or via adapter)
    │
    ▼  stdio transport
Godot MCP Server (Node.js, 25 tools)
    │
    ▼  WebSocket JSON-RPC 2.0
Godot Editor (4.7+) with MCP plugin
```

### Tool Categories (25 total)

| Category | Tools | Purpose |
|----------|-------|---------|
| **Scene** | 7 | Tree inspection, node creation/removal, property editing |
| **Script** | 4 | Script create/edit/read/validate with tween_await() detection |
| **Project** | 3 | Settings read/write, class database queries |
| **Runtime** | 5 | Run/stop/pause scenes, debugger output, log reading |
| **File** | 5 | Browse/read/write/search/delete project files |
| **Visualization** | 1 | Generate project structure graphs |

### Setup

#### 1. Build the MCP server

```bash
cd mcp-bridge/godot-mcp-server
npm install
npm run build
```

#### 2. Configure your agent

**pi-agent**: Create `~/.pi/mcp-config/global.mcp.json`:
```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["<path-to-godot-skills>/mcp-bridge/godot-mcp-server/dist/index.js"]
    }
  }
}
```

**Claude Code**: Create `.mcp.json` in your project root (see `mcp-bridge/pi-mcp-config/claude-code.mcp.json`).

**Cursor / Windsurf**: Add the MCP config to your project-level settings (see `mcp-bridge/pi-mcp-config/.mcp.json`).

#### 3. Start Godot editor with MCP plugin

The Godot editor must be running with the MCP bridge plugin enabled on `ws://127.0.0.1:6789`.

### Graceful Degradation

Phase 1 skills work independently of the MCP bridge. If the editor is not running:
- Skills fall back to static knowledge without live editor access
- MCP tool calls return error code `-32000` (Godot editor not responding)
- Agents handle this gracefully and continue with available knowledge

For full details, see [mcp-bridge/README.md](mcp-bridge/README.md) and [mcp-bridge/protocol.md](mcp-bridge/protocol.md).

## Cross-Agent Compatibility

This package is compatible with:

| Agent | Status |
|-------|--------|
| pi-agent | Full support |
| Claude Code | Via `.claude/skills/` |
| Codex CLI (OpenAI) | Via `.codex/skills/` |
| Gemini CLI | Partial support |
| Cursor | Partial support |
| Cline | Via `.cline/skills/` |
| Kiro | Emerging support |

Each skill follows the [Agent Skills Open Standard](https://agentskills.io/specification) with proper SKILL.md frontmatter (name, description), progressive disclosure, and agent-specific extensions in `agents/` subdirectories.

## Installation for Other Agents

### Claude Code
```bash
# Copy skills to Claude Code's skills directory
cp -r /path/to/godot-skills/skills ~/.claude/skills/
```

### Codex CLI (OpenAI)
```bash
# Copy skills to Codex CLI's skills directory
cp -r /path/to/godot-skills/skills ~/.codex/skills/
```

### Cline
```bash
# Copy skills to Cline's skills directory
cp -r /path/to/godot-skills/skills ~/.cline/skills/
```

## Package Structure

```
godot-skills/
├── package.json           # npm package with pi manifest
├── README.md              # This file
├── AGENTS.md              # Cross-agent usage guide
├── LICENSE                # MIT License
├── docs/
│   ├── architecture.md    # Design decisions and ADRs
│   ├── migration-4.7.md   # Godot 4.7 migration guide
│   └── contributing.md    # Contributor guide
├── skills/
│   ├── godot-project-setup/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── godot-brainstorming/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── godot-gdscript-patterns/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── godot-csharp-patterns/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── godot-code-review/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── godot-debugging/
│   │   ├── SKILL.md
│   │   └── references/
│   └── godot-47-migration/
│       ├── SKILL.md
│       └── references/
│   ├── godot-physics/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── godot-animation/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── godot-ui/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── godot-performance/
│   │   ├── SKILL.md
│   │   └── references/
│   └── godot-networking/
│       ├── SKILL.md
│       └── references/
├── scripts/
│   ├── new-godot-project.sh
│   └── validate-gdscript.gd
├── mcp-bridge/            # Phase 2: Optional MCP server
│   ├── README.md
│   ├── godot-mcp-server/
│   └── pi-mcp-config/
└── examples/              # Reference projects
    ├── minimal-rpg/
    ├── platformer-2d/
    └── multiplayer-lobby/
```

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

See [docs/contributing.md](docs/contributing.md) for contribution guidelines.

---

Built for the [Agent Skills Open Standard](https://agentskills.io) ecosystem.
