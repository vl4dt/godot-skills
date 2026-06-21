# ADR-001: Package Distribution Model

**Status:** Accepted  
**Date:** 2026-06-21

## Context
We need to distribute Godot development skills to 30+ coding agents through a single package.

## Decision
Use dual distribution: npm package (`@vl4dt/godot-skills`) for pi-agent and git repository for other agents. Each skill is a self-contained directory with its own SKILL.md.

## Consequences
- **Pros:** Widest reach, standard tooling support, easy updates via npm
- **Cons:** Requires npm account, scoped package name adds verbosity
- **Alternatives considered:** Unscoped package (simpler but harder to find), GitHub-only distribution (misses npm ecosystem)
