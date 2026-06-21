# ADR-002: Progressive Disclosure Strategy

**Status:** Accepted  
**Date:** 2026-06-21

## Context
Multiple skills loaded simultaneously can overwhelm agent context windows.

## Decision
Keep each SKILL.md under 500 lines. Move detailed content to `references/` subdirectories. Use the Agent Skills standard's progressive disclosure mechanism.

## Consequences
- **Pros:** Smaller system prompt, faster initial load, better context window utilization
- **Cons:** Extra read operations when references are needed
- **Alternatives considered:** Single monolithic skill (too large), inline everything (context overflow risk)
