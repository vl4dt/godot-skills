---
name: godot-state-management
description: "State management patterns for Godot 4.x: enum-based state, finite state machines (FSM), hierarchical FSM, and behavior trees for AI. Use when implementing character states, game flow, menu systems, or AI decision-making in Godot."
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
    - state-machine
    - fsm
    - behavior-tree
    - ai
  created: 2026-06-21
---

# State Management in Godot

Patterns for managing game and entity states cleanly.

## Enum-Based State (Simple)

For straightforward state tracking without transitions:

```gdscript
class_name PlayerController extends CharacterBody2D

enum State { IDLE, RUNNING, JUMPING, FALLING, ATTACKING }

var current_state: State = State.IDLE
var velocity: Vector2

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            _handle_idle(delta)
        State.RUNNING:
            _handle_running(delta)
        State.JUMPING:
            _handle_jumping(delta)
        State.FALLING:
            _handle_falling(delta)
        State.ATTACKING:
            _handle_attacking(delta)

func set_state(new_state: State) -> void:
    if current_state == new_state:
        return
    current_state = new_state
```

## Finite State Machine (FSM)

For entities with defined transitions between states:

```gdscript
class_name FSM extends Node

signal state_entered(state_name: StringName)
signal state_exited(state_name: StringName)

var current_state: FSMState = null
var states: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child is FSMState:
            states[child.name] = child

func initialize(initial: StringName) -> void:
    if not states.has(initial):
        push_error("FSM: Initial state '%s' not found" % initial)
        return
    current_state = states[initial]
    current_state.enter()
    state_entered.emit(initial)

func change_state(new_state_name: StringName) -> void:
    if not states.has(new_state_name):
        push_error("FSM: State '%s' not found" % new_state_name)
        return
    if current_state:
        current_state.exit()
        state_exited.emit(current_state.name)
    current_state = states[new_state_name]
    current_state.enter()
    state_entered.emit(new_state_name)

func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)

func _unhandled_input(event: InputEvent) -> void:
    if current_state:
        current_state.handle_input(event)
```

### FSM State Base Class

```gdscript
class_name FSMState extends Node

func enter() -> void:
    pass  # Override

func exit() -> void:
    pass  # Override

func update(delta: float) -> void:
    pass  # Override

func handle_input(event: InputEvent) -> void:
    pass  # Override

# Helper to transition from within a state
func request_state(fsm: FSM, new_state: StringName) -> void:
    fsm.change_state(new_state)
```

### Concrete State Example

```gdscript
# EnemyIdle.gd extends FSMState
class_name EnemyIdle extends FSMState

@export var idle_timer: float = 2.0
var _timer: float = 0.0

func enter() -> void:
    _timer = 0.0

func update(delta: float) -> void:
    _timer += delta
    if _timer >= idle_timer:
        get_parent().request_state(get_parent().get_node("FSM"), "Patrol")
```

## Hierarchical State Machine

For nested states (e.g., combat has sub-states for melee/range):

```gdscript
class_name HierarchicalFSM extends Node

var current_parent: StringName = ""
var current_child: StringName = ""

# Parent states: "Exploring", "Combat", "Dead"
# Combat child states: "Melee", "Ranged", "Dodging"

func enter_state(parent: StringName, child: StringName) -> void:
    current_parent = parent
    current_child = child
```

### Hierarchical State Pattern

```gdscript
# PlayerCombatState.gd — parent state delegates to children
class_name PlayerCombatState extends FSMState

var sub_states: Dictionary = {}
var active_sub_state: StringName = ""

func enter() -> void:
    # Register sub-states from child nodes
    for child in get_children():
        if child is FSMState:
            sub_states[child.name] = child

func update(delta: float) -> void:
    # Choose sub-state based on context
    var new_sub_state = _determine_sub_state()
    if new_sub_state != active_sub_state:
        _switch_sub_state(new_sub_state)
    if sub_states.has(active_sub_state):
        sub_states[active_sub_state].update(delta)

func _determine_sub_state() -> StringName:
    # Example: switch based on weapon type or enemy distance
    return "Melee"
```

## Behavior Trees (AI)

For complex AI decision-making:

```gdscript
class_name BehaviorTree extends Node

var root_node: BTNode = null

func tick(delta: float, blackboard: Dictionary) -> BTNode.Status:
    if not root_node:
        root_node = get_child(0)
    return root_node.execute(blackboard, delta)

# Blackboard — shared data between nodes
# { "target": Node, "health": int, "last_seen_pos": Vector2 }
```

### BT Node Types

```gdscript
class_name BTNode extends Node

enum Status { SUCCESS, FAILURE, RUNNING }

func execute(blackboard: Dictionary, delta: float) -> Status:
    return Status.SUCCESS  # Override in subclasses

# --- Composite Nodes ---

class_name Sequence extends BTNode
func execute(bb: Dictionary, delta: float) -> Status:
    for child in get_children():
        if child is BTNode:
            var result = child.execute(bb, delta)
            if result != Status.SUCCESS:
                return result
    return Status.SUCCESS

class_name Selector extends BTNode
func execute(bb: Dictionary, delta: float) -> Status:
    for child in get_children():
        if child is BTNode:
            var result = child.execute(bb, delta)
            if result == Status.SUCCESS:
                return Status.SUCCESS
    return Status.FAILURE

# --- Leaf Nodes ---

class_name Condition extends BTNode
func check(blackboard: Dictionary) -> bool:
    return true  # Override

func execute(bb: Dictionary, _delta: float) -> Status:
    return Status.SUCCESS if check(bb) else Status.FAILURE

class_name Action extends BTNode
@export var duration: float = 0.0
var elapsed: float = 0.0

func do_action(blackboard: Dictionary) -> void:
    pass  # Override

func execute(bb: Dictionary, delta: float) -> Status:
    if duration > 0:
        elapsed += delta
        do_action(bb)
        return Status.SUCCESS if elapsed >= duration else Status.RUNNING
    else:
        do_action(bb)
        return Status.SUCCESS
```

## Godot 4.7 State Notes

- **tween_await()** — Use for state transitions with animated duration: `await get_tree().create_tween().tween_property(...) .finished`
- **AnimationTree** — Combine FSM logic with AnimationTree state machines for visual feedback

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools can inspect and modify your project live:

- **`scene_tree`** — Inspect scene hierarchy to audit FSM node structure
- **`script_read`** / **`script_edit`** — Read and modify state machine scripts

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [FSM Implementation Guide](references/fsm-guide.md)
- [Behavior Tree Patterns](references/behavior-trees.md)
- [Hierarchical FSM Examples](references/hierarchical-fsm.md)
