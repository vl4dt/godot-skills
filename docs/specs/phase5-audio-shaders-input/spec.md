# Phase 5: Audio, Shaders/VFX, Input Handling

## Problem / Opportunity

Phase 1–3 cover core gameplay systems but omit three critical sensory domains: audio engineering, visual effects (shaders/particles), and input handling. These are fundamental to game feel and polish.

## Users / Actors

- Game developers needing audio mixing, shader programming, or input remapping guidance
- AI agents helping users implement sound effects, visual polish, or controller support
- Mobile developers needing touch/virtual joystick patterns (beyond VirtualJoystick basics)

## Goals

- Deliver skills for Godot's audio, visual effects, and input subsystems
- Cover both 2D and 3D shader/particle patterns
- Include accessibility considerations (subtitles, remappable controls, audio cues)

## Non-goals

- Not a comprehensive shader programming tutorial (focus on Godot Shader Language patterns)
- Not music composition or sound design advice
- Not third-party tool integration (FMOD, Wwise) — that's Phase 8 territory

## Requirements

### Skills to create

| Skill | Domain | Key Topics |
|-------|--------|------------|
| `godot-audio` | Sound/audio | AudioStreamPlayer hierarchy, bus mixing, spatial audio (2D/3D), randomization, dynamic music, AudioListener patterns |
| `godot-shaders-vfx` | Visual effects | Godot Shader Language basics, canvas_item/vertex/spatial shaders, particle systems (GPUParticles2D/3D), shader materials, post-processing |
| `godot-input` | Input handling | Input map configuration, action polling vs events, gamepad/virtual joystick support, input remapping UI, dead zones, touch/multi-touch |

### Each skill must include

- SKILL.md with valid frontmatter (name, description, license, compatibility, metadata)
- `agents/claude-code.yaml` and `agents/openai.yaml` with safety notices
- `references/` directory with detailed pattern documentation
- Godot 4.7 feature callouts where applicable (e.g., improved particle systems)

## Acceptance Criteria

- 3 new skills created, all ≤500 lines SKILL.md
- All skills pass `scripts/validate-skills.sh`
- Shader examples compile against Godot 4.7 shader syntax
- Input skill covers keyboard, mouse, gamepad, and touch
- Audio skill covers bus routing and spatial audio patterns

## Risks

- **Shader complexity**: Godot's shader language is Turing-complete — risk of overwhelming SKILL.md
- **Platform variance**: Audio formats and particle performance vary wildly by platform
- **Input abstraction**: Godot's input system changed significantly from 3.x to 4.x — need clear migration notes

## Open Questions / Assumptions

- Should `godot-shaders-vfx` include compute shader patterns? (Godot 4.2+ support)
- Audio skill: include procedural audio generation or stick to playback/mixing?
- Input skill: cover Godot's new InputActionEvent API in depth?
