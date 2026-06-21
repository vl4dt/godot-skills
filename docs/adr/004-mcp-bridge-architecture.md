# ADR-004: MCP Bridge Architecture

**Status:** Accepted  
**Date:** 2026-06-21

## Context
Phase 2 requires live Godot editor integration for enhanced agent capabilities.

## Decision
Build a lightweight, standalone Node.js MCP server that connects to the Godot editor via WebSocket and exposes tools through stdio. This is outside pi-agent's built-in support (pi has no MCP), so it will be an optional add-on.

## Consequences
- **Pros:** Compatible with all MCP clients, optional/standalone, graceful degradation
- **Cons:** Additional maintenance burden, outside pi-agent's native capabilities
- **Alternatives considered:** Build as pi-agent extension (limits compatibility), skip MCP entirely (misses live editor integration)
