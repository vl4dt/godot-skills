---
name: godot-ui
description: "UI systems for Godot 4.x: Control node hierarchy, containers and layout modes (Anchor, Margin, Center, Fill, Expand), theme resources, custom styles, RichTextLabel formatting, PopupMenu search, and control offset transforms. Use when building menus, HUDs, inventory screens, or any UI in Godot."
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
    - ui
    - control
    - container
    - theme
    - rich-text
  created: 2026-06-20
---

# UI Systems for Godot 4.x

Comprehensive patterns for user interfaces, menus, and HUD elements in Godot 4.x.

## Control Node Hierarchy and Containers

### Container Types

Godot 4.x provides several container nodes for responsive UI layouts.

```gdscript
# Vertical layout
var vbox = VBoxContainer.new()
vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
add_child(vbox)

# Horizontal layout
var hbox = HBoxContainer.new()
hbox.add_child(Button.new())
hbox.add_child(Button.new())
vbox.add_child(hbox)

# Grid layout
var grid = GridContainer.new()
grid.columns = 3
for i in range(9):
    var btn = Button.new()
    btn.text = str(i)
    grid.add_child(btn)
vbox.add_child(grid)
```

### Anchor Presets

Use anchor presets for responsive positioning.

```gdscript
# Top-left corner, stays fixed
button.set_anchors_preset(Control.PRESET_TOP_LEFT)

# Full screen (fills parent)
panel.set_anchors_preset(Control.PRESET_FULL_RECT)

# Centered with margins
label.set_anchors_preset(Control.PRESET_CENTER)
label.offset_left = -100
label.offset_right = 100
```
## Layout Modes (Anchor, Margin, Center, Fill, Expand)

### Anchor Mode

Control how a node positions itself relative to its parent.

```gdscript
# Manual anchor setup
control.anchor_right = 1.0   # Right edge sticks to parent right
control.offset_right = -20   # But 20px from the edge
control.anchor_bottom = 1.0
control.offset_bottom = -20
```

### Margin Container

Add padding around a child node.

```gdscript
var margin = MarginContainer.new()
margin.add_theme_constant_override("margin_left", 16)
margin.add_theme_constant_override("margin_top", 16)
margin.add_theme_constant_override("margin_right", 16)
margin.add_theme_constant_override("margin_bottom", 16)
margin.add_child(content_panel)
```

### Center Container

Center a child node within its parent.

```gdscript
var center = CenterContainer.new()
center.horizontal_alignment = CenterContainer.ALIGNMENT_CENTER
center.vertical_alignment = CenterContainer.ALIGNMENT_MIDDLE
center.add_child(dialog_panel)
```

### Fill and Expand

```gdscript
# Fill available space
button.expand_mode = Button.BUTTON_EXPAND_FILL  # Fill width and height
button.expand_mode = Button.BUTTON_EXPAND       # Fill width only

# Control fills parent rect
control.size_flags_horizontal = Control.SIZE_FILL
control.size_flags_vertical = Control.SIZE_FILL
```
## Theme Resources and Custom Styles

### Creating a Custom Theme

```gdscript
# Create theme in code
var theme = Theme.new()

# Custom font
var custom_font = FontFile.new()
custom_font.font_data = load("res://fonts/my_font.tres")
theme.add_font("Default", "Source", custom_font)
theme.default_font_size = 16

# Custom button style
var normal_style = StyleBoxTexture.new()
normal_style.texture = load("res://ui/button_normal.png")
normal_style.set_margin_left(8)
normal_style.set_margin_right(8)
normal_style.set_margin_top(4)
normal_style.set_margin_bottom(4)

var hover_style = normal_style.duplicate()
hover_style.modulate = Color(1.2, 1.2, 1.2)  # Lighter on hover

theme.add_stylebox("normal", "Button", normal_style)
theme.add_stylebox("hover", "Button", hover_style)
```

### Theme Overrides per Control

```gdscript
# Override theme on individual controls
button.add_theme_color_override("font_color", Color.WHITE)
button.add_theme_font_size_override("font_size", 20)
button.add_theme_stylebox_override("normal", custom_style)

# Apply theme to entire scene tree
add_child(button)
button.theme = theme
```

### Theme Variation Pattern

```gdscript
# Create themed button scenes for consistency
# ui_button_primary.tscn, ui_button_secondary.tscn, etc.
const PRIMARY_BTN = preload("res://ui/button_primary.tscn")
const SECONDARY_BTN = preload("res://ui/button_secondary.tscn")

func create_primary_button(text: String) -> Button:
    var btn = PRIMARY_BTN.instantiate()
    btn.text = text
    return btn
```
## RichTextLabel Formatting and Image Sizing

### RichTextEffect Custom Tags

Godot 4.x supports custom rich text effects.

```gdscript
# Use built-in BBCode tags in RichTextLabel
rich_text_label.text = "[color=red]Alert![/color] Health is low."
rich_text_label.text = "[b]Bold[/b] and [i]italic[/i] text"
rich_text_label.text = "[img=64]res://icons/heart.png[/img] 10/20 HP"

# Custom effect for damage numbers
func _process(delta: float):
    # RichTextLabel processes BBCode every frame
    # For performance, cache formatted text when possible
```

### Image Sizing in RichTextLabel

```gdscript
# Fixed size images
rich_text_label.text = "[img=32]res://icons/coin.png[/img] [img=32]res://icons/coin.png[/img]"

# Scale by font size
rich_text_label.text = "[font_size=48][img=48]res://icons/star.png[/img][/font_size]"

# Responsive sizing using theme font
func get_icon_size() -> int:
    return ThemeDB.get_font("Default").get_height() * 2
```
## Godot 4.7 UI Features

### PopupMenu Search (Godot 4.7)

Godot 4.7 adds search/filtering to PopupMenu for better UX in large menus.

```gdscript
# The PopupMenu now supports search filtering out of the box
# Connect the search_changed signal for custom filtering
@onready var popup_menu = $PopupMenu
@onready var search_line_edit = $SearchField

func _ready():
    search_line_edit.text_changed.connect(_on_search_changed)
    popup_menu.index_pressed.connect(_on_menu_selected)

func _on_search_changed(query: String):
    # Filter menu items based on search query
    for i in range(popup_menu.item_count):
        var item_text = popup_menu.get_item_text(i)
        popup_menu.set_item_hidden(i, not item_text.containsn(query))
```

### Control Offset Transforms (Godot 4.7)

Godot 4.7 allows animating control offsets directly for smooth UI transitions.

```gdscript
# Animate panel sliding in using offset transforms
func slide_in(panel: Control):
    panel.offset_left = -300  # Start off-screen
    var tween = create_tween()
    tween.tween_property(panel, "offset_left", 0, 0.3)
    tween.set_ease(Tween.EASE_OUT)

func slide_out(panel: Control):
    var tween = create_tween()
    tween.tween_property(panel, "offset_left", -300, 0.25)
    tween.connect("finished", panel.queue_free)

# Use for: sliding menus, notifications, dialog entrances
```
## UI Performance Tips

- Use **Container** nodes instead of manually positioning controls
- Prefer **Anchor presets** over manual offset adjustments when possible
- Cache `RichTextLabel` formatted text when content does not change
- Use `TextureRect` with `STRETCH_SCALE` for responsive images
- Avoid creating/destroying UI nodes every frame — use pooling instead
- Set `visible_ratio` to 0 on off-screen panels instead of queue_free()

## Quick Reference: Container Nodes

| Container | Layout |
|-----------|--------|
| `HBoxContainer` | Horizontal row |
| `VBoxContainer` | Vertical column |
| `GridContainer` | Grid with fixed columns |
| `CenterContainer` | Centered child |
| `MarginContainer` | Padded child |
| `ScrollContainer` | Scrollable area |
| `AspectRatioContainer` | Fixed aspect ratio |
| `Control` (root) | Full rect anchor |

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools enhance UI debugging:

- **`ui_inspect`** — Inspect the current control tree and their properties
- **`ui_preview_theme`** — Preview theme changes in real-time
- **`ui_resize_preview`** — Test responsive layouts at different screen sizes
- **`ui_find_control`** — Find controls by path or name in the scene tree

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [Control Node Documentation](references/control-reference.md)
- [Container Layout Patterns](references/container-patterns.md)
- [Theme Resource Guide](references/theme-resources.md)