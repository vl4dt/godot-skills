# Release Process

This document describes how to release a new version of `@vl4dt/godot-skills`.

## Versioning Scheme

This package follows [Semantic Versioning](https://semver.org/):

| Component | Bump When |
|-----------|-----------|
| **Major** (`2.0.0`) | Breaking changes to skill format, API contract, or minimum Godot version |
| **Minor** (`1.1.0`) | New skills, new MCP tools, backward-compatible feature additions |
| **Patch** (`1.0.1`) | Bug fixes, documentation updates, typo corrections |

## Pre-Release Checklist

Run these steps before tagging a release:

### 1. Verify All Checks Pass
```bash
# Full verification suite
bash scripts/verify.sh

# Skill validation (all skills)
bash scripts/validate-skills.sh

# Lint checks
bash scripts/lint-skills.sh

# Agent extension validation
bash scripts/check-agent-extensions.sh
```

**Expected output:** All checks pass, zero errors.

### 2. Update CHANGELOG.md
Add a new section at the top (below `## [Unreleased]`):

```markdown
## [X.Y.Z] — YYYY-MM-DD

### Added
- New skill: godot-example (description)

### Changed
- Updated godot-physics to cover VirtualJoystick (4.7)

### Fixed
- Corrected collision layer example in godot-project-setup
```

See [docs/changelog-guide.md](changelog-guide.md) for format details.

### 3. Update package.json Version
```bash
# Edit package.json — change "version" field
# Example: "1.0.0" → "1.1.0"
```

### 4. Commit Changes
```bash
git add -A
git commit -m "chore: prepare vX.Y.Z release"
```

### 5. Tag the Release
```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin main --tags
```

## npm Publish Steps

```bash
# Login (if not already authenticated)
npm login

# Dry-run first
npm publish --dry-run

# Publish to npm
npm publish --access public
```

> **Note:** The package is scoped (`@vl4dt/godot-skills`), so `--access public` is required for the initial publish.

## GitHub Release Steps

1. Navigate to [GitHub Releases](https://github.com/vl4dt/godot-skills/releases)
2. Click "Draft a new release"
3. Select the tag (`vX.Y.Z`)
4. Title: `vX.Y.Z — <brief summary>`
5. Body: Copy the CHANGELOG section for this version
6. Check "This is a pre-release" if applicable
7. Click "Publish release"

## Post-Release Verification

```bash
# Verify npm package is published
npm view @vl4dt/godot-skills version

# Verify GitHub tag exists
git ls-remote --tags origin | grep vX.Y.Z

# Test installation from npm
npm install @vl4dt/godot-skills@X.Y.Z --dry-run
```

## Release Cadence

Releases are **event-driven**, not on a fixed schedule. Typical triggers:
- New skill added to the package
- Multiple bug fixes accumulated
- Godot version compatibility update needed
- MCP bridge API changes

## Rollback Procedure

If a release has issues:

1. **npm unpublish** (within 72 hours):
   ```bash
   npm unpublish @vl4dt/godot-skills@X.Y.Z
   ```

2. **Delete GitHub tag**:
   ```bash
   git tag -d vX.Y.Z
   git push origin --delete vX.Y.Z
   ```

3. **Publish corrected version** with incremented patch number.

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable releases, always publishable |
| `release/*` | Release preparation and testing |
| `feature/*` | Individual skill or feature development |
| `hotfix/*` | Urgent fixes for released versions |

---

**Last updated:** 2026-06-21
