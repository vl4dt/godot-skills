# Phase 4: Advanced Game Architecture Skills

## Problem / Opportunity

Phase 1–3 cover language patterns, engine systems, and core domains. Game developers need architectural guidance for complex game structures that go beyond individual systems — entity composition, state management, persistence, localization, and economy systems are the next gap.

## Users / Actors

- Mid-to-senior Godot developers building complete games (not just learning the engine)
- AI agents helping users scaffold full game architectures
- Teams needing consistent patterns for multiplayer-ready architecture

## Goals

- Deliver skills covering architectural patterns used in production Godot games
- Each skill must be independently useful (progressive disclosure compatible)
- Cover both 2D and 3D architectural concerns
- Provide resource-based patterns where Godot's Resource system excels

## Non-goals

- Not a game engine tutorial (assumes Godot fundamentals known)
- Not engine modification guidance (that's GDExtension/C++ territory)
- Not gameplay balance or design advice

## Requirements

### Skills to create

| Skill | Domain | Key Topics |
|-------|--------|------------|
| `godot-architecture` | General architecture | ECS patterns in Godot, scene composition, dependency injection via signals, service locator vs direct reference |
| `godot-state-management` | State machines | Enum-based state, finite state machines (FSM), hierarchical FSM, behavior trees for AI |
| `godot-save-systems` | Persistence | Resource-based save files, JSON vs binary, versioning/migration, cloud save integration patterns |
| `godot-i18n` | Localization | Translation server, .csv/.po/.json formats, runtime language switching, RTL text support, font fallback |
| `godot-dialog-systems` | Dialogue/narrative | Resource-based dialogue trees, branching narratives, typewriter effects, voice sync |
| `godot-inventory-economy` | Items/economy | Resource-based item definitions, stackable/unique items, drag-drop UI patterns, save integration |

### Each skill must include

- SKILL.md with valid frontmatter (name, description, license, compatibility, metadata)
- `agents/claude-code.yaml` and `agents/openai.yaml` with safety notices
- `references/` directory with detailed pattern documentation
- Godot 4.7 feature callouts where applicable

## Acceptance Criteria

- 6 new skills created, all ≤500 lines SKILL.md
- All skills pass `scripts/validate-skills.sh`
- No agent-specific leakage in SKILL.md files
- Each skill has ≥2 concrete code examples
- Agent-specific extensions present for all skills

## Risks

- **Scope creep**: Architecture patterns can become opinionated — need to stay descriptive, not prescriptive
- **Overlap with existing skills**: Must not duplicate `godot-brainstorming` or `godot-gdscript-patterns`
- **Godot version drift**: Save system APIs may change between 4.x versions

## Open Questions / Assumptions

- Should `godot-architecture` cover GDExtension architecture patterns? (Currently scoped to GDScript/C# only)
- Dialogue systems: include external tool references (Yarn Spinner, Ink) or stay Godot-native?
- Inventory systems: include networking considerations or defer to `godot-networking`?
