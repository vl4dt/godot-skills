---
name: godot-input
description: "Input handling patterns for Godot 4.x: Input map configuration, action polling vs events, gamepad/virtual joystick support, input remapping UI, dead zones, and touch/multi-touch. Use when implementing player controls, controller support, or input customization in Godot."
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
    - input
    - controls
    - gamepad
    - touch
    - remapping
  created: 2026-06-21
---

# Input Handling in Godot

Patterns for robust, accessible input systems.

## Input Map Configuration

Define actions in **Project Settings → Input Map** or via code:

```gdscript
# Register actions at runtime (or use editor)
InputMap.add_action("move_left")
InputMap.action_add_event("move_left", InputEventKey.new())

var left_event = InputEventKey.new()
left_event.keycode = KEY_A
InputMap.action_add_event("move_left", left_event)

# Add gamepad button
var dpad_event = InputEventJoypadButton.new()
dpad_event.button_index = JOY_BUTTON_DPAD_LEFT
dpad_event.pressed = true
InputMap.action_add_event("move_left", dpad_event)
```

### Recommended Action Naming

```
move_left, move_right, move_up, move_down
jump, crouch, interact, attack
inventory, pause, menu_confirm, menu_cancel
```

## Polling vs Events

Two approaches to reading input:

### Polling (Continuous — `_physics_process`)

For movement and analog input:

```gdscript
class_name PlayerController extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(delta: float) -> void:
    # Input.get_action_strength returns 0.0 to 1.0
    # Automatically combines keyboard + gamepad inputs
    var input_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    var input_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

    var direction = Vector2(input_x, input_y).normalized()
    velocity = direction * speed

    move_and_slide()
```

### Events (Discrete — `_unhandled_input`)

For camera rotation, menu navigation, one-shot actions:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        interact_with_target()
    elif event.is_action_pressed("pause"):
        toggle_pause()

# Use _unhandled_input so UI can consume input first
# Use _input if this node should always receive input
```

### When to Use Each

| Approach | Use For | Method |
|----------|---------|--------|
| Polling | Movement, analog sticks, continuous actions | `_physics_process` / `_process` |
| Events | Camera rotation, one-shot actions, menu nav | `_unhandled_input` |
| Both | Games with movement + discrete actions | Combined |

## Gamepad Support

### Detecting Connected Controllers

```gdscript
func _ready() -> void:
    var connected = Input.get_connected_joypads()
    if connected.size() > 0:
        print("Gamepad connected: ", connected[0])
        # Enable rumble, vibrate, etc.
```

### Rumble / Haptic Feedback

```gdscript
# Simple rumble on action
func play_rumble(strength: float = 0.5, duration: float = 0.1) -> void:
    Input.start_joy_vibration(0, strength, strength, duration)

# Dual-motor (separate weak/strong rumble)
Input.start_joy_vibration(0, 0.3, 0.8, 0.2)  # weak, strong, duration
```

### Dead Zone Configuration

Prevent drift from analog sticks:

```gdscript
# Set global dead zone (Project Settings → Input Devices → Keyboard/Mouse → Joystick Dead Zone)
# Or per-action in code:
Input.set_deadzone_value(0.15)  # Default is typically 0.15-0.25

# Custom dead zone for specific input reading
func get_analog_input(action_name: String, dead_zone: float = 0.15) -> float:
    var value = Input.get_action_strength(action_name)
    if value < dead_zone:
        return 0.0
    # Remap from [dead_zone, 1.0] to [0.0, 1.0]
    return (value - dead_zone) / (1.0 - dead_zone)
```

## Input Remapping UI

Let players customize controls:

```gdscript
class_name InputRemapButton extends Button

var current_action: String = ""
var waiting_for_input: bool = false

func _ready():
    pressed.connect(_on_button_pressed)

func set_action(action: String) -> void:
    current_action = action
    update_display()

func _on_button_pressed() -> void:
    if waiting_for_input:
        return
    waiting_for_input = true
    text = "Press a key..."
    # Grab focus so input events come here
    grab_focus()

func _input(event: InputEvent) -> void:
    if not waiting_for_input:
        return

    if event is InputEventKey or event is InputEventJoypadButton:
        # Clear old bindings for this action
        var old_events = InputMap.action_get_events(current_action)
        for old_event in old_events:
            InputMap.action_remove_event(current_action, old_event)

        # Add new binding
        InputMap.action_add_event(current_action, event.duplicate())
        waiting_for_input = false
        update_display()
        get_viewport().set_input_as_handled()  # Prevent game from receiving it

func update_display() -> void:
    if not waiting_for_input:
        var events = InputMap.action_get_events(current_action)
        if events.size() > 0:
            text = _event_to_string(events[0])
        else:
            text = "Not assigned"

func _event_to_string(event: InputEvent) -> String:
    if event is InputEventKey:
        return OS.get_keycode_string(event.keycode)
    elif event is InputEventJoypadButton:
        return "Gamepad Button %d" % event.button_index
    return "Unknown"
```

### Saving Remapped Controls

```gdscript
class_name InputSettings extends Node

const SETTINGS_PATH := "user://input_settings.cfg"

func save_bindings() -> void:
    var config = ConfigFile.new()
    var actions = InputMap.get_actions()

    for action in actions:
        var events = InputMap.action_get_events(action)
        var event_strings = []
        for event in events:
            event_strings.append(_event_to_string(event))
        config.set_value("input", action, ",".join(event_strings))

    config.save(SETTINGS_PATH)

func load_bindings() -> Error:
    var config = ConfigFile.new()
    if config.load(SETTINGS_PATH) != OK:
        return Error.ERR_FILE_NOT_FOUND

    var actions = InputMap.get_actions()
    for action in actions:
        var event_strings = config.get_value("input", action, "") as String
        if event_strings.is_empty():
            continue

        # Clear and re-add
        var old_events = InputMap.action_get_events(action)
        for old_event in old_events:
            InputMap.action_remove_event(action, old_event)

        for str in event_strings.split(","):
            var event = _string_to_event(str)
            if event:
                InputMap.action_add_event(action, event)

    return Error.OK

func _event_to_string(event: InputEvent) -> String:
    if event is InputEventKey:
        return "key:%d" % event.keycode
    elif event is InputEventJoypadButton:
        return "joypad:%d" % event.button_index
    return ""

func _string_to_event(str: String) -> InputEvent:
    var parts = str.split(":")
    if parts[0] == "key":
        var event = InputEventKey.new()
        event.keycode = int(parts[1])
        return event
    elif parts[0] == "joypad":
        var event = InputEventJoypadButton.new()
        event.button_index = int(parts[1])
        event.pressed = true
        return event
    return null
```

## Touch and Multi-Touch

### Virtual Joystick (Godot 4.7+)

```gdscript
# Godot 4.7 includes VirtualJoystick control node
# Place in scene, configure via inspector:
# - Base texture, knob texture
# - Dead zone value
# - Action names for directional output

# Read virtual joystick input:
func _physics_process(delta: float) -> void:
    var joystick = $VirtualJoystick as VirtualJoystick
    if joystick and joystick.is_active():
        var direction = joystick.get_vector()  # Vector2 (-1 to 1)
        velocity = direction * speed
```

### Multi-Touch Gestures

```gdscript
class_name TouchHandler extends Node2D

var _touch_points: Dictionary = {}  # index -> Vector2

func _input(event: InputEvent) -> void:
    if event is InputEventScreenDrag:
        _handle_drag(event)
    elif event is InputEventScreenTouch:
        if event.pressed:
            _touch_points[event.index] = event.position
        else:
            _touch_points.erase(event.index)

func _handle_drag(event: InputEventScreenDrag) -> void:
    if _touch_points.has(event.index):
        var delta = event.position - _touch_points[event.index]
        _touch_points[event.index] = event.position
        # Use delta for movement, camera pan, etc.

# Pinch-to-zoom with two fingers
func get_pinch_scale() -> float:
    var indices = _touch_points.keys()
    if indices.size() < 2:
        return 1.0

    var idx_a = indices[0]
    var idx_b = indices[1]
    var current_dist = _touch_points[idx_a].distance_to(_touch_points[idx_b])
    # Compare to previous frame distance for zoom delta
    return current_dist / maxf(1.0, _get_previous_distance())

var _previous_distance: float = 0.0
func _get_previous_distance() -> float:
    return _previous_distance
```

## Accessibility Patterns

### Hold vs Toggle Actions

```gdscript
# Support both hold and toggle for accessibility
@export var use_toggle_jump: bool = false
var jump_toggled: bool = false

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        if use_toggle_jump:
            jump_toggled = !jump_toggled
        # Movement code checks either:
        # Input.is_action_pressed("jump") OR jump_toggled
```

### Sensitivity Slider

```gdscript
# For camera or aim sensitivity
@export var sensitivity: float = 1.0

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        camera.rotate_y(-event.relative.x * sensitivity * 0.002)
        camera.rotate_x(-event.relative.y * sensitivity * 0.002)
```

## Godot 4.7 Input Notes

- **VirtualJoystick** — New built-in control node for touch-based analog input
- **InputActionEvent** — Enhanced event structure for complex action queries
- **Gamepad** — Improved auto-detection and button mapping consistency

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools can inspect and modify your project live:

- **`project_info`** — Check configured input actions and settings
- **`script_read`** / **`script_edit`** — Read and modify input scripts

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [Input Map Best Practices](references/input-map.md)
- [Gamepad Support Guide](references/gamepad-support.md)
- [Touch Input Patterns](references/touch-input.md)
