# Phase 7: Example Projects

## Problem / Opportunity

The `examples/` directory contains three READMEs with no actual Godot projects. Real, runnable examples are critical for:
- Demonstrating how skills work together in practice
- Providing testable reference implementations
- Enabling "learn by example" usage patterns
- Validating that skill patterns actually compile/run in Godot

## Users / Actors

- New users learning the skill package through concrete examples
- AI agents referencing example code when answering questions
- Contributors verifying their changes against working projects

## Goals

- Convert placeholder READMEs into minimal runnable Godot projects
- Each example demonstrates specific skills from the package
- Projects are small enough to maintain but complete enough to run
- Include project.godot and minimal scene/tree structure

## Non-goals

- Not full production games (scope would be unbounded)
- Not tutorials (skills themselves are the documentation)
- Not asset-heavy projects (keep binary assets out of git)

## Requirements

### Projects to build

| Project | Skills Demonstrated | Scope |
|---------|-------------------|-------|
| `minimal-rpg` | project-setup, gdscript-patterns, physics, animation, ui | Top-down RPG with player movement, collision, inventory UI, animated character |
| `platformer-2d` | project-setup, gdscript-patterns, physics, animation, input | Side-scrolling platformer with player controller, enemies, camera follow, HUD |
| `multiplayer-lobby` | project-setup, networking, ui, gdscript-patterns | Lobby screen, room creation/joining, player list, ready-up system, scene transition |

### Each project must include

- `project.godot` configured for Godot 4.7
- Minimal scene tree with at least one `.tscn` file
- Core gameplay scripts demonstrating the relevant skills
- `README.md` explaining what to run and what it demonstrates
- No external assets (use Godot built-in shapes/colors)
- `.gdignore` if needed

## Acceptance Criteria

- Each project opens in Godot 4.7 without errors
- Each project runs (`F5`) and shows playable behavior within 10 seconds
- Scripts reference patterns documented in the corresponding skills
- No binary assets committed (use procedural generation or Godot primitives)
- Project directory ≤ 50 files each

## Risks

- **Godot version lock**: Examples may break on minor version upgrades
- **Maintenance burden**: Each example is a mini-project needing updates
- **Asset-free constraint**: May limit visual appeal of examples
- **Scene file format**: `.tscn` files are text-based but verbose — keep minimal

## Open Questions / Assumptions

- Should examples use GDScript or C#? (GDScript chosen as primary, C# variants could be Phase 8)
- Include export presets or assume editor-only? (Editor-only for simplicity)
- Add a test runner script that validates all examples open cleanly? (Defer to Phase 6 CI)
