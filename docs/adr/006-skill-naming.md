# ADR-006: Skill Naming Convention

**Status:** Accepted  
**Date:** 2026-06-21

## Context
Skill names need to be discoverable, unique, and follow the Agent Skills standard.

## Decision
Prefix all skills with `godot-` for clear domain identification. Use kebab-case. Keep names under 64 characters. Names do not need to match directory names (pi-agent allows this deviation from the standard).

## Consequences
- **Pros:** Clear namespace, easy to discover, follows best practices
- **Cons:** Long names for compound skills
- **Alternatives considered:** No prefix (conflicts with other packages), domain-specific prefixes (godot-gdscript vs godot-patterns)
