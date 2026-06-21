# Phase 8: Community, Ecosystem Integration, and Documentation

## Problem / Opportunity

The package is technically complete (12 skills + MCP bridge) but lacks community-facing assets and third-party ecosystem integration. To become a reference-quality open-source project, it needs contributor onboarding, changelog discipline, and awareness of complementary tools in the Godot ecosystem.

## Users / Actors

- New contributors who want to add skills or fix issues
- Package users checking compatibility with their toolchain
- Community members discovering the package through Godot forums/AssetLib

## Goals

- Lower barrier to contribution with templates and guides
- Document Godot ecosystem integrations (AssetLib, plugins, GDExtension)
- Establish release process and versioning convention
- Create community communication channels/references

## Non-goals

- Not user support (that's issue tracker + documentation)
- Not marketing/PR strategy
- Not feature roadmap management (that's beads issues)

## Requirements

### Deliverables

| Artifact | Purpose |
|----------|---------|
| `docs/skill-template/` | Copy-paste template for new skills (SKILL.md skeleton, agents/, references/) |
| `docs/ecosystem.md` | Godot ecosystem integrations: AssetLib plugins, GDExtension patterns, popular community tools |
| `docs/release-process.md` | Versioning scheme, release checklist, npm publish steps, GitHub tagging |
| `scripts/new-skill.sh` | Scaffold a new skill directory from template |
| `docs/changelog-guide.md` | Changelog format conventions and semantic versioning rules |
| Phase 4–5 skills | The actual advanced domain skills (depends on Phase 4/5 completion) |

### Ecosystem documentation

- Godot AssetLib: how to reference/list complementary plugins
- GDExtension: when to recommend C++ vs GDScript/C#
- Popular community tools: Aseprite/Tiled/GIMP importers, audio tools
- Godot forums/discord presence guidelines
- Cross-references to official Godot documentation

## Acceptance Criteria

- `scripts/new-skill.sh` creates a valid skill scaffold in one command
- `docs/skill-template/` passes `scripts/validate-skills.sh` when placed in `skills/`
- `docs/ecosystem.md` covers ≥10 notable Godot ecosystem tools/plugins
- Release process documented with copy-paste commands
- Changelog follows conventional format (Features, Fixes, Breaking)

## Risks

- **Ecosystem churn**: Godot plugins and tools change rapidly — docs may age quickly
- **Scope drift**: Ecosystem docs could become a directory rather than guidance
- **Maintenance**: Release process needs to be followed consistently

## Open Questions / Assumptions

- Versioning: semantic versioning (semver) or calendar versioning? (Semver chosen for npm compatibility)
- Release cadence: fixed schedule or event-driven? (Event-driven, tied to feature completion)
- Community channel: GitHub Discussions, Discord server, or Godot forums? (GitHub Discussions preferred)
