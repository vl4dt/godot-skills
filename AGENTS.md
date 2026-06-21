# Cross-Agent Usage Guide

This document explains how to use @robotcat/godot-skills across different coding agents.

## How Skills Work Across Agents

All skills follow the [Agent Skills Open Standard](https://agentskills.io/specification):

1. **SKILL.md** is the universal entry point — every agent that supports skills uses this file
2. **Progressive disclosure** means only the skill name and description appear in the system prompt; the full SKILL.md loads on-demand when the agent detects a relevant task
3. **Relative paths** from the skill directory work across all agents for scripts, references, and assets

## Agent-Specific Setup

### pi-agent (Recommended)
```bash
pi install npm:@robotcat/godot-skills
# Skills auto-discover from ~/.pi/agent/npm/@robotcat/godot-skills/skills/
```

### Claude Code
```bash
# Install the skills directory to Claude Code's location
cp -r ./skills ~/.claude/skills/godot-skills
# Or symlink for development:
ln -s /path/to/godot-skills/skills ~/.claude/skills/godot-skills
```
Claude Code reads `agents/claude-code.yaml` per skill for tool permissions and trigger conditions.

### Codex CLI (OpenAI)
```bash
cp -r ./skills ~/.codex/skills/godot-skills
```
Codex CLI reads `agents/openai.yaml` per skill for policy settings.

### Cline
```bash
cp -r ./skills ~/.cline/skills/godot-skills
```

### Cursor / Windsurf
These agents use `.cursorrules` or `.windsurfrules` primarily. To use these skills:
1. Reference specific skill content in your `.cursorrules` file
2. Use the skill descriptions as trigger phrases in rules

Example `.cursorrules` addition:
```markdown
When working with Godot game development, follow patterns from @robotcat/godot-skills.
For project setup, use godot-project-setup patterns.
For GDScript code, follow godot-gdscript-patterns guidelines.
```

### Gemini CLI / Kiro
Partial support — copy skills directory to the agent's skills folder and test manually.

## MCP Bridge Setup per Agent

The MCP bridge (Phase 2) provides live Godot editor integration. Below is how to configure it for each agent.

### pi-agent

Create `~/.pi/mcp-config/global.mcp.json`:
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

### Claude Code

Create `.mcp.json` in your project root:
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

Template: `mcp-bridge/pi-mcp-config/claude-code.mcp.json`

### Codex CLI (OpenAI)

Create `~/.codex/mcp.json`:
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

### Cursor / Windsurf

Add the MCP config to your project-level settings. Template: `mcp-bridge/pi-mcp-config/.mcp.json`.

### Cline

Create `~/.cline/mcp.json`:
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

## Agent-Specific Extensions

Each skill may include an `agents/` subdirectory with agent-specific configuration:

```
skills/godot-project-setup/
├── SKILL.md              # Universal skill instructions
└── agents/
    ├── claude-code.yaml  # Claude Code specific settings
    ├── codex.yaml        # Codex CLI specific settings
    └── pi-agent.yaml     # pi-agent specific settings
```

These files are **safely ignored** by agents that don't recognize them. They follow the standard's extension mechanism and contain agent-specific instructions like `when_to_use` conditions or tool permissions.

## Troubleshooting

### Skills not loading
1. Verify the skills directory is in your agent's discovery path
2. Check that each skill has a valid SKILL.md with name and description frontmatter
3. Ensure SKILL.md names use lowercase kebab-case (e.g., `godot-project-setup`)

### Description not triggering
1. Make sure descriptions are specific enough (avoid vague phrases like "helps with Godot")
2. Check the skill's description matches the prompt language your agent uses
3. Try invoking explicitly: `/skill:godot-project-setup` (pi-agent) or equivalent for your agent

### Cross-platform path issues
- On Windows, shell scripts in `scripts/` may need `.ps1` variants
- GDScript paths always use forward slashes regardless of host OS
- All skills assume Godot 4.x is installed and in PATH

## Version Compatibility

| Skill Version | Godot Version | Notes |
|--------------|---------------|-------|
| 0.1.0 | 4.0 - 4.7 | Initial release, targets Godot 4.7 features |
| TBD | 5.0+ | Future compatibility updates |

## Cross-Agent Testing

See [docs/cross-agent-testing.md](docs/cross-agent-testing.md) for the full testing checklist, per-agent instructions, and description trigger matrix.

## Reporting Issues

Report compatibility issues at: https://github.com/robotcat/godot-skills/issues

Include:
- Agent name and version
- SKILL.md that isn't loading or triggering correctly
- Error messages or unexpected behavior
