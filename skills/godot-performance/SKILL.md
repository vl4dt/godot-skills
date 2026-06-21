---
name: godot-performance
description: Performance optimization for Godot 4.x: profiling workflow (built-in profiler, CPU/GPU usage), memory management with ResourceCache and instance pooling, instancing optimization with packed scenes and LOD, render passes, draw calls, mobile-specific optimizations, Perfetto tracing, and nearest-neighbor viewport scaling. Use when debugging performance, optimizing games, or targeting low-end hardware.
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
  author: RoboCat
  version: 0.1.0
  tags:
    - godot
    - performance
    - profiling
    - optimization
    - memory
    - mobile
  created: 2026-06-20
---

# Performance Optimization for Godot 4.x

Systematic approach to profiling, optimizing, and debugging performance in Godot 4.x.

## Profiling Workflow

### Built-in Profiler

Access the profiler via Debug > Start Profiling or press Ctrl+Shift+P.

```gdscript
# Enable profiling in your project settings:
# Project Settings > Debug > Profile Every Frame = true

# Use time measure for specific code sections
var start_time = Time.get_ticks_usec()
# ... expensive operation ...
var elapsed = Time.get_ticks_usec() - start_time
print("Operation took: ", elapsed, " us")
```

### CPU/GPU Usage Monitoring

```gdscript
# Display FPS and frame time in debug overlay
# Project Settings > Debug > Show FPS = true

# Monitor specific metrics
func get_performance_stats():
    var stats = {
        fps: Performance.get_monitor(Performance.TIME_FPS),
        frame_time: Performance.get_monitor(Performance.TIME_FRAME_DURATION),
        draw_calls: Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
        active_objects: Performance.get_monitor(Performance.OBJECT_COUNT),
        mem_alloc: Performance.get_monitor(Performance.MEMORY_STATIC),
        mem_pool: Performance.get_monitor(Performance.MEMORY_STATIC_SPECIALIZATION)
    }
    return stats
```

### Profiling Checklist

1. **Start with a clean build** — Profile the exported release build, not the debug version
2. **Enable all profiler categories** — CPU, GPU, Physics, Rendering, Audio
3. **Record a representative gameplay segment** — 30-60 seconds of typical play
4. **Identify hotspots** — Look for functions consuming >5% of frame time
5. **Profile before and after changes** — Measure impact of each optimization

## Memory Management

### ResourceCache Pattern

Preload and cache frequently-used resources.

```gdscript
class_name ResourceCache extends Node

static var _cache := {}

static func preload_resource(path: String) -> Variant:
    if not _cache.has(path):
        var res = load(path)
        if res:
            _cache[path] = res
        else:
            push_warning("Failed to load resource: " + path)
    return _cache[path]

static func get_scene(path: String) -> PackedScene:
    return preload_resource(path) as PackedScene

# Usage
var bullet_scene = ResourceCache.get_scene("res://scenes/entities/bullet.tscn")
var bullet = bullet_scene.instantiate()
```

### Instance Pooling Pattern

Reuse objects instead of creating/destroying them.

```gdscript
class_name ObjectPool<T> extends Node where T is RefCounted

@export var pool_size: int = 20
var _pool: Array[T] = []
var _active: Array[T] = []

func _ready():
    for i in range(pool_size):
        var instance = create_instance()
        instance.set_process_mode(PROCESS_MODE_ALWAYS)
        add_child(instance as Node)
        _pool.append(instance as T)

func get_free() -> T:
    if _pool.size() > 0:
        var obj = _pool.pop_back()
        obj.set_active(true)
        _active.append(obj)
        return obj
    return null

func release(obj: T) -> void:
    obj.set_active(false)
    _active.erase(obj)
    _pool.append(obj)
```
## Instancing Optimization

### Packed Scene Best Practices

```gdscript
# preload() for always-needed scenes (compile-time)
const BulletScene = preload("res://scenes/entities/bullet.tscn")

func spawn_bullet():
    var bullet = BulletScene.instantiate()
    add_child(bullet)

# load() for conditional scenes (runtime)
func load_level(level_name: String):
    var path = "res://levels/" + level_name + ".tscn"
    var scene = load(path)  # Cached by Godot internally
    if scene:
        current_level = scene.instantiate()
        add_child(current_level)
```

### Level of Detail (LOD)

Use LOD to reduce rendering cost for distant objects.

```gdscript
class_name LODObject extends Node3D

@export var lod_distances: PackedFloat32Array = [10.0, 30.0, 60.0]
@onready var lod_nodes = [$HighDetail, $MediumDetail, $LowDetail]

func _process():
    var dist = global_position.distance_to(get_viewport().get_camera3D().global_position)
    for i in range(lod_nodes.size()):
        lod_nodes[i].visible = dist < lod_distances[i]
```

### Instanced Rendering

Use `MultiMeshInstance2D/3D` for many similar objects.

```gdscript
# Draw 1000 identical trees with a single draw call
var mesh = preload("res://models/tree.tscn")
var multi_mesh = MultiMesh.new()
multi_mesh.mesh = mesh.resource
multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
multi_mesh.instance_count = 1000

for i in range(1000):
    var x = randf() * 200 - 100
    var z = randf() * 200 - 100
    multi_mesh.set_instance_transform(i, Transform3D(Basis(), Vector3(x, 0, z)))

$MultiMeshInstance3D.multi_mesh = multi_mesh
```
## Render Passes and Draw Calls

### Minimizing Draw Calls

```gdscript
# BAD: Many small sprites (many draw calls)
for i in range(100):
    var sprite = Sprite2D.new()
    sprite.texture = grass_texture
    add_child(sprite)

# GOOD: Use TileMap or MultiMesh (single draw call)
# TileMap handles batching automatically
# Or use a custom mesh with instanced rendering
```

### Render Pass Optimization

- **Forward+** renderer: Better for many lights, use for 3D games
- **Mobile** renderer: Fewer passes, better for low-end devices
- **Stencil shadows**: Use shadow maps instead of volumetric shadows when possible
- **LightmapGI**: Bake static lighting to avoid real-time shadows

```gdscript
# Set renderer in Project Settings > Rendering > Renderer
# Forward Plus: Better quality, higher cost
# Mobile: Optimized for low-end hardware
```
## Mobile-Specific Optimizations

### Texture Compression

```gdscript
# Project Settings > Export > Android/iOS
# Set texture format:
# - ASTC: Best quality/size ratio (modern devices)
# - ETC2: Fallback for older Android devices
# - DXT: Desktop only
# Use compressed textures in the editor:
# Texture > Compressed = True
```

### Mobile Rendering Tips

- Use **Mobile renderer** instead of Forward+ for Android/iOS
- Limit active lights per object (use light masks)
- Bake static lighting with LightmapGI
- Use smaller shadow map sizes (512x512 or 256x256)
- Disable post-processing effects when not needed
- Use `CanvasGroup` to batch UI rendering
- Set `texture_filter` to `TEXTURE_FILTER_NEAREST` for pixel art

### CPU Optimization for Mobile

- Avoid `_get_node()` in _process — use `@onready` instead
- Minimize `_instantiate()` calls — use object pooling
- Use `NavigationServer3D` for pathfinding (avoids scene tree overhead)
- Batch physics queries instead of individual raycasts
- Use `PhysicsServer3D` directly for bulk operations

## Godot 4.7 Performance Features

### Perfetto Tracing for Android (Godot 4.7)

Perfetto provides detailed profiling data for Android builds.

```gdscript
# Enable in Project Settings > Debug
# Perfetto tracing captures:
# - Frame timing breakdown
# - GC pauses
# - Thread scheduling
# - GPU command queue

# After export, run:
# godot --perfetto-trace output.perfetto
# Then open in https://ui.perfetto.dev/
```

### Nearest-Neighbor Viewport Scaling (Godot 4.7)

Pixel-perfect scaling for retro-style games.

```gdscript
# Project Settings > Display > Window > Stretch Mode
stretch_mode = CanvasGroup.STRETCH_MODE_SCALE
stretch_aspect = CanvasGroup.STRETCH_ASPECT_KEEP

# Godot 4.7: Use nearest-neighbor scaling for crisp pixel art
texture_filter = TextureFilter.NEAREST

# Calculate integer scale factor
func get_viewport_scale() -> int:
    var target_width = 320  # Original game resolution
    return max(1, int(DisplayServer.window_get_size().x / target_width))
```
## Performance Checklist

### Before Release

- [ ] Profile the release build (not debug)
- [ ] Check FPS stays above 30 (60 ideal) on target hardware
- [ ] Verify memory usage stays within device limits
- [ ] Test on lowest-spec target device
- [ ] Check for GC spikes (>1ms pauses)
- [ ] Verify texture compression is enabled
- [ ] Reduce draw calls with instancing
- [ ] Use lightmaps for static scenes
- [ ] Implement object pooling for frequently spawned entities

### Runtime Monitoring

```gdscript
# Add to debug HUD
class_name PerfHUD extends CanvasLayer

@onready var fps_label = $FPSLabel
@onready var mem_label = $MemLabel

func _process(delta):
    fps_label.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
    mem_label.text = "Mem: " + str(Performance.get_monitor(Performance.MEMORY_STATIC) / 1024 / 1024) + " MB"
```
## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools enhance performance debugging:

- **`profiler_start`** — Start a profiling session from the editor
- **`profiler_stop`** — Stop and display results
- **`memory_stats`** — View current memory allocation breakdown
- **`render_stats`** — Query draw calls, triangles, and active textures
- **`perfetto_export`** — Export Perfetto trace for Android debugging

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [Profiler Documentation](references/profiler-guide.md)
- [Memory Management Patterns](references/memory-patterns.md)
- [Mobile Optimization Checklist](references/mobile-checklist.md)