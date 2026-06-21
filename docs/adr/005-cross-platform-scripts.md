# ADR-005: Cross-Platform Script Handling

**Status:** Accepted  
**Date:** 2026-06-21

## Context
Users run on Windows, macOS, and Linux. Godot itself is cross-platform.

## Decision
Shell scripts use POSIX-compatible syntax where possible. Provide `.ps1` variants for Windows PowerShell users. GDScript paths always use forward slashes (Godot's cross-platform convention).

## Consequences
- **Pros:** Works on all platforms, follows Godot conventions
- **Cons:** Some users need platform-specific script variants
- **Alternatives considered:** Platform-specific skills (maintenance nightmare), pure Node.js scripts (adds runtime dependency)
