# Godot 4.7 Migration Guide

This guide covers the key changes in Godot 4.7 that affect game development patterns and agent skill implementations.

## New Features in Godot 4.7

### Rendering & Visual
- **HDR output settings** — Project settings now support HDR output configuration for compatible displays
- **New AreaLight3D node** — Enhanced area lighting with improved performance and new modes
- **Nearest-neighbor viewport scaling** — Better pixel-perfect rendering for retro-style games

### UI & Controls
- **VirtualJoystick for mobile** — Built-in virtual joystick support, replacing third-party solutions
- **PopupMenu search** — Native search functionality in popup menus
- **Control offset transforms** — New transform system for UI animation with improved performance
- **Collapsible animation tracks** — AnimationTrackEdit now supports collapsing tracks for better organization

### Animation & Sequencing
- **tween_await()** — New method to await tween completion within code, enabling sequential animation chains without callback nesting
- **DrawableTexture2D** — Dynamic texture creation at runtime for procedural UI and rendering

### Android & Mobile
- **Perfetto tracing** — Built-in Perfetto tracing support for Android performance profiling
- **Android XR settings** — New project settings for extended reality development

### Steam Integration
- **Steam Frame configuration** — Enhanced Steam integration with frame-based overlay support

## Migration Checklist for Existing Godot 4.x Projects

### From Godot 4.6 to 4.7

1. **Update project.godot** — Open in Godot 4.7 editor to auto-migrate settings
2. **Review HDR settings** — Enable HDR output in Project Settings > Rendering > Environment if needed
3. **Replace VirtualJoystick custom nodes** — If using third-party virtual joysticks, consider migrating to the built-in VirtualJoystick node
4. **Update tween callbacks** — Replace nested callback patterns with `tween_await()` for cleaner code
5. **Check AreaLight3D usage** — Review existing area lights for new 4.7 features (modes, intensity profiles)
6. **Test Android builds** — Verify Perfetto tracing works if targeting Android profiling
7. **Review Steam Frame config** — If using Steam integration, update frame configuration

### Breaking Changes to Watch For

- **VirtualJoystick API changes** — If using custom virtual joystick implementations, review the new built-in node API
- **tween_await() replacement** — Code relying on complex tween callback chains should migrate to await syntax
- **HDR rendering pipeline** — Projects without explicit HDR settings may see visual differences; test critical scenes

### Deprecated Features

No major deprecations in 4.7, but monitor the [Godot changelog](https://github.com/godotengine/godot/releases) for future version compatibility.

## Code Examples

### Before: Nested tween callbacks (4.6 and earlier)
```gdscript
func play_sequential():
    var tween = create_tween()
    tween.tween_property($Sprite, "position:x", 100, 1.0)
    tween.finished.connect(func():
        var tween2 = create_tween()
        tween2.tween_property($Sprite, "position:y", 50, 0.5)
    )
```

### After: Using tween_await() (4.7+)
```gdscript
func play_sequential():
    await create_tween().tween_property($Sprite, "position:x", 100, 1.0).finished
    await create_tween().tween_property($Sprite, "position:y", 50, 0.5).finished
```

### New: VirtualJoystick (4.7+)
```gdscript
# No custom implementation needed — use the built-in node
# Add VirtualJoystick node to your scene, configure in editor
func _input(event: InputEvent) -> void:
    if event is InputEventJoypadMotion:
        # Built-in axis handling
        pass
```

## Further Reading

- [Godot 4.7 Changelog](https://github.com/godotengine/godot/releases)
- [Godot Documentation](https://docs.godotengine.org/en/stable/)
- [Godot 4 Migration Guide](https://godotengine.org/article/migration-guide-godot-4/)
