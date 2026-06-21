# Cross-Agent Testing Documentation

This document describes how to test @vl4dt/godot-skills across supported coding agents.

## Validation Checklist

Run these checks before publishing or releasing a new version:

### 1. SKILL.md Standard Compliance

| Check | Command | Expected |
|-------|---------|----------|
| All SKILL.md files exist | `find skills/*/SKILL.md` | 7 files |
| Valid YAML frontmatter | `grep -c '^name:\|^description:\|^license:' skills/*/SKILL.md` | ≥3 per file |
| Progressive disclosure (<500 lines) | `wc -l skills/*/SKILL.md` | All <500 |
| Kebab-case naming | `ls skills/` | All match `godot-*` pattern |

### 2. Agent-Specific Extensions

| Check | Command | Expected |
|-------|---------|----------|
| agents/ directory exists per skill | `find skills/*/agents -type d` | 7 dirs |
| claude-code.yaml present | `find skills/*/agents/claude-code.yaml` | 7 files |
| openai.yaml present | `find skills/*/agents/openai.yaml` | 7 files |
| Safety notice present | `grep -rl 'Safely ignored' skills/*/agents/` | 14 files |

### 3. No Agent-Specific Leakage

| Check | Command | Expected |
|-------|---------|----------|
| No Python try/except in GDScript | `grep -rn '^\s*try:' --include='*.gd' skills/` | 0 results |
| No Claude Code syntax in SKILL.md | `grep -rl 'claude-code' --include='SKILL.md' skills/` | 0 results |
| No OpenAI-specific tools in SKILL.md | `grep -rl 'openai\|codex' --include='SKILL.md' skills/` | 0 results |

### 4. Script References

| Check | Command | Expected |
|-------|---------|----------|
| new-godot-project.sh exists | `test -f scripts/new-godot-project.sh` | true |
| validate-gdscript.gd exists | `test -f scripts/validate-gdscript.gd` | true |
| References use relative paths | `grep 'scripts/' skills/*/SKILL.md` | Relative only |

## Per-Agent Testing Instructions

### pi-agent

```bash
# Install from local path
pi install ./path/to/godot-skills -l

# Verify skill discovery
pi skills list

# Test each skill by description trigger
# e.g., prompt: "help me set up a new Godot project"
# Should trigger: godot-project-setup
```

### Claude Code

```bash
# Copy skills directory
cp -r /path/to/godot-skills/skills ~/.claude/skills/

# Verify by checking skill files are readable
ls ~/.claude/skills/godot-*/SKILL.md

# Test with a prompt like: "I want to design game architecture for an RPG"
```

### Codex CLI (OpenAI)

```bash
# Copy skills directory
cp -r /path/to/godot-skills/skills ~/.codex/skills/

# Verify by checking skill files are readable
ls ~/.codex/skills/godot-*/SKILL.md

# Test with a prompt like: "help me debug a Godot error"
```

### Cline

```bash
# Copy skills directory
cp -r /path/to/godot-skills/skills ~/.cline/skills/

# Verify by checking skill files are readable
ls ~/.cline/skills/godot-*/SKILL.md
```

### Cursor / Windsurf

These agents use `.cursorrules` or `.windsurfrules`. Test by:

1. Adding the example rules from `AGENTS.md` to your project's `.cursorrules`
2. Opening a Godot project in Cursor/Windsurf
3. Prompting with skill-relevant queries

## Description Trigger Matrix

| Skill | Trigger Phrase Examples |
|-------|------------------------|
| godot-project-setup | "create new Godot project", "scaffold Godot", "Godot folder structure" |
| godot-brainstorming | "design game architecture", "state machine Godot", "multiplayer setup" |
| godot-gdscript-patterns | "write GDScript", "Godot signals", "node composition" |
| godot-csharp-patterns | "C# Godot", "Mono patterns", "Export attributes" |
| godot-code-review | "review Godot code", "performance checklist", "memory leak" |
| godot-debugging | "debug Godot", "profiler", "Godot error" |
| godot-4.7-migration | "upgrade to Godot 4.7", "Godot migration", "new Godot features" |

## Automated Validation Script

Save as `scripts/validate-skills.sh` for CI integration:

```bash
#!/bin/bash
set -e
cd "$(dirname "$0")/.."

errors=0

# Check all SKILL.md files have required frontmatter
for skill_dir in skills/*/; do
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || { echo "MISSING: $skill_md"; errors=$((errors+1)); continue; }
    
    for field in name description license; do
        grep -q "^$field:" "$skill_md" || { echo "MISSING frontmatter: $field in $(basename $skill_dir)"; errors=$((errors+1)); }
    done
    
    lines=$(wc -l < "$skill_md")
    [ "$lines" -lt 500 ] || { echo "TOO LONG: $(basename $skill_dir) has $lines lines"; errors=$((errors+1)); }
done

# Check agent extensions
for skill_dir in skills/*/; do
    for agent_file in claude-code.yaml openai.yaml; do
        [ -f "$skill_dir/agents/$agent_file" ] || { echo "MISSING: agents/$agent_file in $(basename $skill_dir)"; errors=$((errors+1)); }
    done
done

# Check package.json
node -e "const d=require('./package.json'); if(!d.pi?.skills) throw new Error('missing pi manifest');" 2>/dev/null || { echo "ERROR: package.json invalid"; errors=$((errors+1)); }

[ "$errors" -eq 0 ] && echo "All checks passed!" || { echo "$errors check(s) failed"; exit 1; }
```

## Publishing Checklist

- [x] All SKILL.md files pass frontmatter validation
- [x] All SKILL.md bodies under 500 lines (max: 231 — godot-csharp-patterns)
- [x] Skill names follow kebab-case with `godot-` prefix
- [x] Agent-specific extensions present for all 7 skills (14 files total)
- [x] No agent-specific features leak into core SKILL.md instructions
- [x] package.json has scoped npm name (`@vl4dt/godot-skills`) and pi manifest
- [x] LICENSE is MIT
- [x] pi-package keyword present in package.json
- [x] README.md, AGENTS.md, docs/contributing.md present
- [x] Total package size under 1MB (current: 115K)

## Known Limitations

- Gemini CLI and Kiro have partial/unknown support — test manually
- Cursor/Windsurf require manual `.cursorrules` configuration
- Agent-specific YAML files are safely ignored by agents that don't recognize them, but may appear as unknown config warnings in strict-mode agents
