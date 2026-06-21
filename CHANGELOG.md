# Changelog

All notable changes to @vl4dt/godot-skills.

Format: [Keep a Changelog](https://keepachangelog.com/) | Versioning: [SemVer](https://semver.org/)
See [docs/changelog-guide.md](docs/changelog-guide.md) for conventions.

## [Unreleased]

### Added
- `scripts/new-skill.sh` — Scaffold new skill directories from template
- `docs/skill-template/` — Copy-paste skill template (SKILL.md, agents/, references/)
- `docs/ecosystem.md` — Godot ecosystem integrations guide (20+ tools/plugins)
- `docs/release-process.md` — Release checklist, npm publish steps, rollback procedure
- `docs/changelog-guide.md` — Changelog format conventions and semver rules

## [1.0.0] — 2026-06-20

### Added — Phase 1: Core Standalone Skills
- `godot-project-setup` — Project scaffolding with .gdignore, export presets, autoload setup
- `godot-brainstorming` — Architecture patterns, state machines, network architecture
- `godot-gdscript-patterns` — Node composition, typed signals, scene instantiation, singletons
- `godot-csharp-patterns` — Export attributes, signal handling, performance optimization
- `godot-code-review` — Performance checklist, anti-patterns, memory management
- `godot-debugging` — Output methods, profiler workflow, common error patterns

### Added — Phase 2: MCP Bridge
- MCP server (Node.js) with 25 tools across 6 categories (scene, script, project, runtime, file, visualization)
- Godot connector via WebSocket JSON-RPC 2.0
- Agent-specific MCP config templates (pi-agent, Claude Code, Cursor/Windsurf)
- Graceful degradation when editor is not running

### Added — Phase 3: Advanced Game Dev Domains
- `godot-physics` — Collision layers/masks, rigid body dynamics, character controllers, area triggers, physics interpolation
- `godot-animation` — AnimationPlayer vs AnimationTree, state machines, blend spaces (1D/2D/directional), root motion, tween_await()
- `godot-ui` — Control hierarchy, containers and layout modes, themes, RichTextLabel, PopupMenu search, control offset transforms (4.7)
- `godot-performance` — Profiling workflow, memory management, instancing/LOD, draw calls, mobile optimization, Perfetto tracing
- `godot-networking` — RPC system, authority models, replication patterns (rpc/rset/rset_group), lag compensation, Steam Frame

### Added — Package Infrastructure
- `package.json` with pi manifest (`pi.skills: ["skills/*"]`) and npm scoped name `@vl4dt/godot-skills`
- MIT License
- Cross-agent compatibility via Agent Skills Open Standard
- Agent-specific extensions (`agents/claude-code.yaml`, `agents/openai.yaml`) for all 12 skills
- `scripts/new-godot-project.sh` — POSIX shell project scaffolding
- `scripts/validate-gdscript.gd` — Headless GDScript syntax validator
- `scripts/validate-skills.sh` — Automated skill validation for CI
- 3 example projects (minimal-rpg, platformer-2d, multiplayer-lobby)

### Added — Documentation
- `README.md` — Full package documentation with skill table and installation guides
- `AGENTS.md` — Cross-agent installation guide for pi-agent, Claude Code, Codex CLI, Cline, Cursor/Windsurf, Gemini CLI, Kiro
- `docs/architecture.md` — 6 Architecture Decision Records
- `docs/migration-4.7.md` — Godot 4.7 migration checklist with code examples
- `docs/contributing.md` — Contributor guide with skill creation workflow
- `docs/cross-agent-testing.md` — Cross-agent testing documentation and checklist
- `mcp-bridge/README.md` — MCP bridge architecture and setup guide
- `mcp-bridge/protocol.md` — MCP protocol specification
- `mcp-bridge/tools.md` — MCP tools reference

### Godot 4.7 Feature Coverage
All 12 skills cover the following Godot 4.7 features where applicable:
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

### Cross-Agent Compatibility
Designed and tested for:
- pi-agent (native via `package.json` manifest)
- Claude Code (via `.claude/skills/`)
- Codex CLI / OpenAI (via `.codex/skills/`)
- Cline (via `.cline/skills/`)
- Cursor / Windsurf (via `.cursorrules`)
- Gemini CLI (partial support)
- Kiro (emerging support)

## [0.1.0] — 2026-06-21 (Initial development)

### Added
- Initial package structure and architecture
- First 7 core skills
- Basic documentation
- MCP bridge design documents

---

## Versioning

This package follows [Semantic Versioning](https://semver.org/):
- **Major** — Breaking changes to skill format or API
- **Minor** — New skills, new features (backward compatible)
- **Patch** — Bug fixes, documentation updates
