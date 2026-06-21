# Changelog Guide

This document describes the changelog format and conventions for `@vl4dt/godot-skills`.

## Format

The changelog follows a **[Keep a Changelog](https://keepachangelog.com/)** inspired format with adaptations for this package.

### Entry Structure

```markdown
## [X.Y.Z] — YYYY-MM-DD

### Added
- New feature or skill

### Changed
- Backward-compatible behavior change

### Deprecated
- Soon-to-be-removed feature (with migration path)

### Removed
- Removed deprecated feature

### Fixed
- Bug fix

### Security
- Security-related fix
```

### Section Order

Always use this order (omit empty sections):

1. **Added** — New skills, tools, features
2. **Changed** — Modifications to existing behavior
3. **Deprecated** — Features marked for removal
4. **Removed** — Features removed in this version
5. **Fixed** — Bug fixes
6. **Security** — Security patches

## Entry Guidelines

### Be Specific

**Good:**
```markdown
### Added
- `godot-animation` skill covering AnimationPlayer, AnimationTree, blend spaces, and tween_await()
```

**Bad:**
```markdown
### Added
- Animation improvements
```

### Reference Skills by Name

Always use the full skill name in backticks:
```markdown
- Updated `godot-physics` to document VirtualJoystick (Godot 4.7+)
```

### Include Godot Version Context

When changes relate to specific Godot versions:
```markdown
### Changed
- All skills now reference Godot 4.7 features where applicable
- `godot-ui` updated for Control offset transforms (4.7)
```

### Link to Issues

When a change addresses a tracked issue:
```markdown
### Fixed
- Corrected collision layer values in `godot-physics` (#42)
```

## Unreleased Section

Maintain an `## [Unreleased]` section at the top for ongoing work:

```markdown
## [Unreleased]

### Added
- Work in progress skill: godot-new-feature

### Changed
- Refactoring MCP bridge tool registration
```

When releasing, rename `## [Unreleased]` to `## [X.Y.Z] — YYYY-MM-DD`.

## Semantic Versioning Rules

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| New skill added | Minor (`1.0.0` → `1.1.0`) | Adding `godot-tweening` |
| Skill content expanded (no breaking change) | Patch or Minor | Adding patterns to existing skill |
| Skill renamed or removed | Major | Removing `godot-old-skill` |
| MCP bridge API change | Minor (compatible) / Major (breaking) | New RPC endpoints |
| Documentation-only fix | Patch | Typo correction, clarifying text |
| Godot version bump requirement | Major | Requiring 4.7+ instead of 4.0+ |

## Frontmatter Requirements

Each release in CHANGELOG.md includes:
- Version number in brackets: `## [1.2.3]`
- ISO date: `— YYYY-MM-DD`
- Sections with categorized entries

## Automation

The `scripts/verify.sh` script checks that CHANGELOG.md exists and has content. Future automation may include:
- Conventional commit parsing for automatic changelog generation
- Pre-publish checklist validation
- Version consistency check (package.json vs git tag)

---

**Last updated:** 2026-06-21
