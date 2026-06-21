# Architecture Decision Records

## ADR-001: Package Distribution Model

**Status:** Accepted  
**Date:** 2026-06-21

### Context
We need to distribute Godot development skills to 30+ coding agents through a single package.

### Decision
Use dual distribution: npm package (`@vl4dt/godot-skills`) for pi-agent and git repository for other agents. Each skill is a self-contained directory with its own SKILL.md.

### Consequences
- **Pros:** Widest reach, standard tooling support, easy updates via npm
- **Cons:** Requires npm account, scoped package name adds verbosity
- **Alternatives considered:** Unscoped package (simpler but harder to find), GitHub-only distribution (misses npm ecosystem)

## ADR-002: Progressive Disclosure Strategy

**Status:** Accepted  
**Date:** 2026-06-21

### Context
Multiple skills loaded simultaneously can overwhelm agent context windows.

### Decision
Keep each SKILL.md under 500 lines. Move detailed content to `references/` subdirectories. Use the Agent Skills standard's progressive disclosure mechanism.

### Consequences
- **Pros:** Smaller system prompt, faster initial load, better context window utilization
- **Cons:** Extra read operations when references are needed
- **Alternatives considered:** Single monolithic skill (too large), inline everything (context overflow risk)

## ADR-003: Godot Version Target

**Status:** Accepted  
**Date:** 2026-06-21

### Context
Godot 4.x has multiple minor versions with varying features.

### Decision
Target Godot 4.7 as the primary version, but ensure all patterns are compatible with Godot 4.0+. Document version-specific features clearly in each skill.

### Consequences
- **Pros:** Latest features included, forward-compatible baseline
- **Cons:** Some 4.0 users may encounter unfamiliar APIs
- **Alternatives considered:** Lock to specific 4.x version (too restrictive), support only latest (alienates users)

## ADR-004: MCP Bridge Architecture

**Status:** Accepted  
**Date:** 2026-06-21

### Context
Phase 2 requires live Godot editor integration for enhanced agent capabilities.

### Decision
Build a lightweight, standalone Node.js MCP server that connects to the Godot editor via WebSocket and exposes tools through stdio. This is outside pi-agent's built-in support (pi has no MCP), so it will be an optional add-on.

### Consequences
- **Pros:** Compatible with all MCP clients, optional/standalone, graceful degradation
- **Cons:** Additional maintenance burden, outside pi-agent's native capabilities
- **Alternatives considered:** Build as pi-agent extension (limits compatibility), skip MCP entirely (misses live editor integration)

## ADR-005: Cross-Platform Script Handling

**Status:** Accepted  
**Date:** 2026-06-21

### Context
Users run on Windows, macOS, and Linux. Godot itself is cross-platform.

### Decision
Shell scripts use POSIX-compatible syntax where possible. Provide `.ps1` variants for Windows PowerShell users. GDScript paths always use forward slashes (Godot's cross-platform convention).

### Consequences
- **Pros:** Works on all platforms, follows Godot conventions
- **Cons:** Some users need platform-specific script variants
- **Alternatives considered:** Platform-specific skills (maintenance nightmare), pure Node.js scripts (adds runtime dependency)

## ADR-006: Skill Naming Convention

**Status:** Accepted  
**Date:** 2026-06-21

### Context
Skill names need to be discoverable, unique, and follow the Agent Skills standard.

### Decision
Prefix all skills with `godot-` for clear domain identification. Use kebab-case. Keep names under 64 characters. Names do not need to match directory names (pi-agent allows this deviation from the standard).

### Consequences
- **Pros:** Clear namespace, easy to discover, follows best practices
- **Cons:** Long names for compound skills
- **Alternatives considered:** No prefix (conflicts with other packages), domain-specific prefixes (godot-gdscript vs godot-patterns)
