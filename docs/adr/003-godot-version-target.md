# ADR-003: Godot Version Target

**Status:** Accepted  
**Date:** 2026-06-21

## Context
Godot 4.x has multiple minor versions with varying features.

## Decision
Target Godot 4.7 as the primary version, but ensure all patterns are compatible with Godot 4.0+. Document version-specific features clearly in each skill.

## Consequences
- **Pros:** Latest features included, forward-compatible baseline
- **Cons:** Some 4.0 users may encounter unfamiliar APIs
- **Alternatives considered:** Lock to specific 4.x version (too restrictive), support only latest (alienates users)
