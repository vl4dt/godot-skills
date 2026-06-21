# Contributing to @robotcat/godot-skills

Thank you for your interest in contributing! This document covers how to contribute skills, fix issues, and improve the package.

## Getting Started

### Prerequisites
- Godot 4.7 editor (for testing skill content accuracy)
- Basic understanding of the [Agent Skills Open Standard](https://agentskills.io/specification)
- Familiarity with pi-agent package conventions

### Setup
```bash
# Clone the repository
git clone https://github.com/robotcat/godot-skills.git
cd godot-skills

# Test skill loading in pi-agent (local)
pi --skill ./skills/godot-project-setup "Test skill loading"
```

## Adding a New Skill

### 1. Create the skill directory
```bash
mkdir -p skills/godot-new-skill/references
```

### 2. Write SKILL.md
```markdown
---
name: godot-new-skill
description: Specific description of what this skill does and when to use it. Be specific about the Godot-related task.
license: MIT
---

# Godot New Skill

## Overview
Brief description of what this skill covers.

## Usage
Instructions for using this skill.

## References
See [references/DETAIL.md](references/DETAIL.md) for detailed content.
```

### 3. Add references (if needed)
```markdown
---
name: godot-new-skill-detail
description: Detailed reference for godot-new-skill.
---

# Detailed Reference

Detailed content that would exceed the 500-line SKILL.md limit.
```

### 4. Test
- Verify the skill loads in pi-agent without warnings
- Check that description triggers correctly
- Ensure relative paths work
- Validate name follows kebab-case rules (<=64 chars, lowercase only)

## Skill Quality Checklist

- [ ] SKILL.md has valid YAML frontmatter (name, description required)
- [ ] Name is <=64 chars, lowercase kebab-case
- [ ] Description is specific and actionable (not "helps with Godot")
- [ ] SKILL.md body is under 500 lines
- [ ] References are in `references/` subdirectory
- [ ] All relative paths resolve correctly
- [ ] Godot 4.7 features documented where applicable
- [ ] Cross-platform considerations noted (Windows paths, etc.)

## Making Changes to Existing Skills

1. Fork the repository
2. Create a feature branch: `git checkout -b improve-godot-debugging`
3. Make your changes
4. Test locally with pi-agent
5. Submit a pull request

## Pull Request Guidelines

- Keep PRs focused (one skill or one topic per PR)
- Update relevant docs if changing patterns
- Include Godot 4.7 notes for new features covered
- Run `pi --skill ./skills/<skill-name> "Test"` to verify loading

## Code of Conduct

This project follows the Agent Skills Open Standard community guidelines. Be respectful, inclusive, and constructive in all interactions.
