# godot-skills — Project Context

## What is this?

`@robotcat/godot-skills` is a distributable, open-source skill package for AI coding agents. It provides domain knowledge, best practices, and patterns for **Godot 4.x game development** with full Godot 4.7 feature coverage. Compatible with pi-agent and 30+ other coding agents via the [Agent Skills Open Standard](https://agentskills.io).

## Domain Language

| Term | Meaning |
|------|---------|
| **Skill** | A self-contained directory with `SKILL.md` (frontmatter + body) that an agent loads on-demand. Max 500 lines per SKILL.md. |
| **Progressive disclosure** | Only name/description appear in system prompt; full SKILL.md loads when the agent detects a relevant task. |
| **Agent Skills Open Standard** | The spec at agentskills.io governing SKILL.md format, progressive disclosure, and agent-specific extensions. |
| **Agent-specific extension** | Files in `agents/` subdirectory (e.g., `claude-code.yaml`, `openai.yaml`) ignored by agents that don't recognize them. |
| **MCP Bridge** | Optional Node.js MCP server connecting AI agents to a running Godot editor via WebSocket JSON-RPC 2.0. |
| **Godot 4.7 features** | HDR output, Steam Frame, AreaLight3D, VirtualJoystick, `tween_await()`, collapsible tracks, PopupMenu search, control offset transforms, Perfetto tracing, nearest-neighbor scaling, DrawableTexture2D. |

## Current State

### Completed (v1.0.0)

| Phase | Scope | Skills Delivered |
|-------|-------|-----------------|
| **Phase 1** | Core standalone skills + package infrastructure + cross-agent testing | `godot-project-setup`, `godot-brainstorming`, `godot-gdscript-patterns`, `godot-csharp-patterns`, `godot-code-review`, `godot-debugging`, `godot-47-migration` |
| **Phase 2** | MCP bridge server + editor integration | 25 MCP tools (scene, script, project, runtime, file, visualization) |
| **Phase 3** | Advanced domain skills | `godot-physics`, `godot-animation`, `godot-ui`, `godot-performance`, `godot-networking` |

### Package Structure

```
godot-skills/
├── package.json              # npm + pi manifest (v1.0.0)
├── README.md / AGENTS.md     # User docs + cross-agent guide
├── LICENSE                   # MIT
├── CHANGELOG.md              # Versioned changelog
├── CODE_OF_CONDUCT.md        # Contributor Covenant v2.1
├── CONTRIBUTING.md           # Root redirect → docs/contributing.md
├── .gitignore                # Godot-aware ignores
├── docs/
│   ├── architecture.md       # 6 ADRs (distribution, disclosure, version, MCP, cross-platform, naming)
│   ├── migration-4.7.md      # Godot 4.7 migration checklist
│   ├── contributing.md       # Contributor guide + quality checklist
│   └── cross-agent-testing.md
├── skills/                   # 12 skills total
│   ├── godot-project-setup/
│   ├── godot-brainstorming/
│   ├── godot-gdscript-patterns/
│   ├── godot-csharp-patterns/
│   ├── godot-code-review/
│   ├── godot-debugging/
│   ├── godot-47-migration/
│   ├── godot-physics/
│   ├── godot-animation/
│   ├── godot-ui/
│   ├── godot-performance/
│   └── godot-networking/
├── scripts/
│   ├── new-godot-project.sh  # POSIX project scaffolding
│   ├── validate-gdscript.gd  # Headless GDScript syntax validator
│   └── validate-skills.sh    # Agent Skills Open Standard validation
├── mcp-bridge/               # Phase 2 MCP server (built, TypeScript → dist/)
│   ├── README.md / protocol.md / tools.md
│   ├── godot-mcp-server/     # Node.js MCP server (25 tools)
│   └── pi-mcp-config/        # Agent-specific MCP config templates
└── examples/                 # 3 placeholder projects (READMEs only)
    ├── minimal-rpg/
    ├── platformer-2d/
    └── multiplayer-lobby/
```

### Distribution Status

- Package ready for `npm publish` as `@robotcat/godot-skills`
- GitHub repo at `github.com/robotcat/godot-skills` (needs creation/tagging)
- 51/51 validation checks pass (s10 final verification)

## Key Constraints

1. **SKILL.md ≤ 500 lines** — progressive disclosure requirement
2. **No agent-specific content in SKILL.md** — extensions go in `agents/` subdir
3. **Each skill needs** `claude-code.yaml` + `openai.yaml` with safety notices
4. **Godot 4.7 primary, 4.0+ compatible** — version-specific features clearly marked
5. **Cross-platform scripts** — POSIX shell + `.ps1` variants for Windows
6. **GDScript paths always forward slashes** — Godot's cross-platform convention

## Tech Stack

- **Package**: npm (`@robotcat/godot-skills`), MIT license
- **MCP Server**: Node.js + TypeScript, WebSocket JSON-RPC 2.0, stdio transport
- **Target Godot**: 4.7 (primary), 4.0+ (compatible)
- **Languages in skills**: GDScript, C# (Mono)
- **Distribution**: npm registry, GitHub, pi.dev gallery

## Dependencies

- No runtime dependencies for Phase 1/3 skills (pure documentation)
- MCP bridge: `@modelcontextprotocol/sdk` + standard Node.js tooling
- Godot editor (4.7+): required only for MCP bridge live integration
