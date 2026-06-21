---
name: godot-shaders-vfx
description: "Visual effects patterns for Godot 4.x: Godot Shader Language (GSL) basics, canvas_item/vertex/spatial shaders, particle systems (GPUParticles2D/3D), shader materials, and post-processing. Use when implementing custom rendering effects, particles, or visual polish in Godot."
license: MIT
compatibility:
  - godot-4.0
  - godot-4.1
  - godot-4.2
  - godot-4.3
  - godot-4.4
  - godot-4.5
  - godot-4.6
  - godot-4.7
metadata:
  author: vl4dt
  version: 0.1.0
  tags:
    - godot
    - shaders
    - vfx
    - particles
    - post-processing
    - gsl
  created: 2026-06-21
---

# Shaders and Visual Effects in Godot

Patterns for custom rendering and particle effects.

## Shader Types

Godot supports three shader modes:

| Mode | Node Type | Use Case |
|------|-----------|----------|
| `canvas_item` | Sprite2D, TileMap, Control | 2D sprite effects, UI shaders |
| `spatial` | MeshInstance3D, SurfaceTool | 3D material effects |
| `vertex` | Any mesh | Displacement, morphing (no fragment stage) |

## Canvas Item Shader (2D)

Basic 2D shader structure:

```gdscript
// Pixelate effect for retro aesthetics
shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 32.0) = 4.0;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    // Snap UV to pixel grid
    vec2 uv = floor(UV * (1.0 / pixel_size)) * pixel_size;
    vec4 color = texture(TEXTURE, uv);

    // Apply brightness
    color.rgb *= brightness;

    COLOR = color;
}
```

### Applying Shaders in Code

```gdscript
# Apply shader material to a sprite
var shader_mat = ShaderMaterial.new()
shader_mat.shader = preload("res://shaders/pixelate.gdshader")
$Sprite2D.material = shader_mat

# Set uniform at runtime
shader_mat.set_shader_parameter("pixel_size", 8.0)
shader_mat.set_shader_parameter("brightness", 1.5)
```

### Color Tint Shader

```gdscript
// Selective color tint — useful for damage flash, selection highlight
shader_type canvas_item;

uniform vec4 tint_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 original = texture(TEXTURE, UV);
    COLOR = mix(original, original * tint_color, tint_amount);
}
```

## Spatial Shader (3D)

Basic 3D shader with lighting:

```gdscript
// Animated water surface
shader_type spatial;
render_mode unshaded, depth_prepass_alpha_blend;

uniform float wave_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wave_height : hint_range(0.01, 0.5) = 0.1;
uniform vec4 water_color : hint_color = vec4(0.0, 0.5, 0.8, 0.7);

void vertex() {
    // Animate vertices with sine waves
    float wave = sin(UV.x * 10.0 + TIME * wave_speed) * wave_height;
    wave += sin(UV.y * 8.0 + TIME * wave_speed * 1.3) * wave_height * 0.5;
    VERTEX.y += wave;

    // Recalculate normal for lighting
    NORMAL.y += wave * 2.0;
    NORMAL = normalize(NORMAL);
}

void fragment() {
    // Fresnel-like effect — edges more reflective
    float fresnel = pow(1.0 - abs(dot(NORMAL, VIEW_DIR)), 3.0);
    vec3 color = mix(water_color.rgb, vec3(1.0), fresnel * 0.5);

    ALBEDO = color;
    ALPHA = water_color.a;
    SPECULAR = 0.8;
    ROUGHNESS = 0.2;
}
```

## Particle Systems

### GPUParticles2D

```gdscript
# Code-driven particle setup
var particles = GPUParticles2D.new()
particles.one_shot = true
particles.lifetime = 1.5
particles.amount = 50
particles.emitting = false

# Process mode
particles.process_material = ParticleProcessMaterial.new()
particles.process_material.initial_velocity_min = 50.0
particles.process_material.initial_velocity_max = 150.0
particles.process_material.gravity = Vector3(0, -200, 0)
particles.process_material.spread = 360.0

# Visual
particles.material = ParticleMaterial.new()
particles.material.texture = preload("res://assets/particle.png")
particles.material.h_color = Color(1.0, 0.5, 0.0, 1.0)
particles.material.h_color2 = Color(1.0, 1.0, 0.0, 0.0)  # Fade to transparent

add_child(particles)
```

### Triggering Particles

```gdscript
func emit_explosion(position: Vector2) -> void:
    var particles = load("res://vfx/explosion.tscn").instantiate() as GPUParticles2D
    particles.global_position = position
    particles.emitting = true
    get_parent().add_child(particles)

    # Auto-destroy after particles finish
    particles.finished.connect(func(): particles.queue_free())
```

### GPUParticles3D

```gdscript
# 3D particle burst (fire, smoke, magic)
var particles_3d = GPUParticles3D.new()
particles_3d.one_shot = true
particles_3d.lifetime = 2.0
particles_3d.amount = 100

# Directional emission from a cone
particles_3d.direction = Vector3.UP
particles_3d.emitting = false

add_child(particles_3d)
```

## Post-Processing

Apply screen-space effects via WorldEnvironment:

```gdscript
# Access environment settings
var env = get_world_3d().environment

# Glow/bloom
env.glow_enabled = true
env.glow_bloom_intensity = 0.5
env.glow_bloom_soft = true
env.glow_bloom_threshold = 0.8

# Tone mapping
env.tone_mapping = Environment.TONE_MAPPING_ACES

# Fog
env.fog_mode = Environment.FOG_MODE_EXPONENTIATED
env.fog_color = Color(0.6, 0.7, 0.8)
env.fog_density = 0.02

# SSAO (3D ambient occlusion)
env.ssao_enabled = true
env.ssao_max_distance = 5.0
```

### Screen Shader (WorldEnvironment)

For custom full-screen post-processing:

```gdscript
// Vignette + chromatic aberration post-process
shader_type spatial;
render_mode unshaded;

uniform float vignette_amount : hint_range(0.0, 1.0) = 0.5;
uniform float chroma_amount : hint_range(0.0, 0.01) = 0.003;

void fragment() {
    // Chromatic aberration — shift RGB channels radially
    vec2 center = UV - 0.5;
    float dist = length(center);
    vec2 dir = normalize(center) * chroma_amount * dist;

    float r = texture(SCREEN_TEXTURE, UV + dir).r;
    float g = texture(SCREEN_TEXTURE, UV).g;
    float b = texture(SCREEN_TEXTURE, UV - dir).b;

    // Vignette
    float vignette = mix(1.0, 0.0, dist * vignette_amount * 2.0);

    vec3 color = vec3(r, g, b) * vignette;
    COLOR = vec4(color, 1.0);
}
```

## Shader Performance Tips

### Minimize Fragment Operations

```gdscript
// Bad — expensive per-pixel
void fragment() {
    COLOR.rgb = pow(texture(TEXTURE, UV).rgb, 3.0) * sin(TIME * 10.0);
}

// Good — precompute where possible
uniform float precomputed_value;
void fragment() {
    COLOR.rgb = texture(TEXTURE, UV).rgb * precomputed_value;
}
```

### Use `hint_range` for Uniforms

Always constrain uniforms to prevent editor/script errors:

```gdscript
uniform float speed : hint_range(0.1, 10.0) = 1.0;
uniform vec4 color : hint_color = vec4(1.0);
uniform sampler2D tex : hint_black;  // Default black texture fallback
```

### Shader Material Reuse

```gdscript
# Share one ShaderMaterial across multiple nodes for performance
var shared_material = ShaderMaterial.new()
shared_material.shader = preload("res://shaders/wave.gdshader")

$Sprite2D_A.material = shared_material
$Sprite2D_B.material = shared_material  # Same material instance
```

## Godot 4.7 VFX Notes

- **GPUParticles** — Improved burst and emit rate controls
- **Screen shaders** — Enhanced SCREEN_TEXTURE sampling quality
- **render_mode** — New `world_vertex_coords` option for world-space shader effects

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools can inspect and modify your project live:

- **`script_read`** / **`script_edit`** — Read and modify shader scripts
- **`scene_tree`** — Inspect particle node hierarchy and parameters

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [GSL Shader Patterns](references/gsl-patterns.md)
- [Particle System Guide](references/particle-systems.md)
| [Post-Processing Effects](references/post-processing.md)
