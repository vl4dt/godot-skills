---
name: godot-inventory-economy
description: "Inventory and economy patterns for Godot 4.x: resource-based item definitions, stackable/unique items, drag-drop UI, equip systems, currency management, and save integration. Use when building item systems, shops, or economies in Godot games."
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
    - inventory
    - economy
    - items
    - equip
  created: 2026-06-21
---

# Inventory and Economy Systems in Godot

Patterns for item management, equipping, and game economies.

## Resource-Based Item Definitions

Define all items as `Resource` files — no code changes needed for new items:

```gdscript
class_name ItemData extends Resource

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM, MATERIAL }
enum EquipmentSlot { HEAD, CHEST, HANDS, FEET, WEAPON, ACCESSORY }

@export var item_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var item_type: ItemType = ItemType.MATERIAL
@export var stack_size: int = 1  # Max per stack, 0 = unique
@export var value: int = 0  # Gold/sell value
@export var equipment_slot: EquipmentSlot = EquipmentSlot.WEAPON

# Stat modifiers (for equipment)
@export var stat_modifiers: Dictionary = {}  # {"speed": 10, "defense": 5}

# Consumable effects
@export var heal_amount: int = 0
@export var effect_script: Script = null  # Optional custom effect
```

### Item Instance (Runtime)

```gdscript
class_name InventoryItem extends Resource

@export var item_data: ItemData
@export var quantity: int = 1
@export var durability: float = 1.0  # 0.0 to 1.0, -1 = unbreakable
@export var is_equipped: bool = false
```

## Inventory Manager

Core inventory system with stack management:

```gdscript
class_name Inventory extends Node

signal item_added(item: InventoryItem)
signal item_removed(item: InventoryItem)
signal item_equipped(item: InventoryItem, slot: ItemData.EquipmentSlot)
signal item_unequipped(slot: ItemData.EquipmentSlot)
signal inventory_changed()

var items: Array[InventoryItem] = []
var equipped: Dictionary = {}  # slot -> InventoryItem
@export var max_slots: int = 20

func add_item(data: ItemData, quantity: int = 1) -> bool:
    if items.size() >= max_slots:
        return false

    # Try to stack with existing item
    for inv_item in items:
        if inv_item.item_data == data and data.stack_size > 1:
            var remaining = data.stack_size - inv_item.quantity
            if remaining > 0:
                var add_amount = min(quantity, remaining)
                inv_item.quantity += add_amount
                quantity -= add_amount
                item_added.emit(inv_item)
                inventory_changed.emit()
            if quantity <= 0:
                return true

    # Create new stack
    while quantity > 0:
        var new_item = InventoryItem.new()
        new_item.item_data = data
        var add_amount = min(quantity, data.stack_size if data.stack_size > 0 else 1)
        new_item.quantity = add_amount
        new_item.durability = data.stack_size > 1 ? 1.0 : -1.0
        items.append(new_item)
        item_added.emit(new_item)
        quantity -= add_amount

    inventory_changed.emit()
    return true

func remove_item(index: int, quantity: int = 1) -> bool:
    if index < 0 or index >= items.size():
        return false

    var inv_item = items[index]
    if inv_item.quantity <= quantity:
        item_removed.emit(inv_item)
        items.remove_at(index)
    else:
        inv_item.quantity -= quantity
        item_removed.emit(inv_item)

    inventory_changed.emit()
    return true

func equip(item_index: int) -> bool:
    var inv_item = items[item_index]
    var slot = inv_item.item_data.equipment_slot

    # Unequip current item in slot
    if equipped.has(slot):
        unequip(slot)

    inv_item.is_equipped = true
    equipped[slot] = inv_item
    item_equipped.emit(inv_item, slot)
    return true

func unequip(slot: ItemData.EquipmentSlot) -> bool:
    if not equipped.has(slot):
        return false

    var inv_item = equipped[slot]
    inv_item.is_equipped = false
    equipped.erase(slot)
    item_unequipped.emit(slot)
    return true
```

## Drag-and-Drop Inventory UI

Grid-based inventory with drag support:

```gdscript
class_name InventorySlot extends Container

signal slot_clicked(index: int)
signal drag_started(item: InventoryItem, index: int)
signal drop_requested(from_index: int, to_index: int)

var item: InventoryItem = null
var slot_index: int = 0

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT and item:
            drag_started.emit(item, slot_index)

# Handle dropping another item into this slot
func accept_drop(from_slot: InventorySlot) -> bool:
    if not item:
        # Empty slot — move item here
        drop_requested.emit(from_slot.slot_index, slot_index)
        return true
    elif from_slot.item and not item:
        drop_requested.emit(from_slot.slot_index, slot_index)
        return true
    return false

func update_display() -> void:
    # Update child controls (icon, quantity label) based on item
    pass
```

### Inventory Grid

```gdscript
class_name InventoryGrid extends GridContainer

@export var inventory: Inventory
@export var slot_scene: PackedScene

func _ready():
    for i in range(inventory.max_slots):
        var slot = slot_scene.instantiate() as InventorySlot
        slot.slot_index = i
        slot.drag_started.connect(_on_drag_started)
        slot.drop_requested.connect(_on_drop_requested)
        add_child(slot)
    refresh()

func refresh() -> void:
    for child in get_children():
        if child is InventorySlot:
            var slot = child as InventorySlot
            if slot.slot_index < inventory.items.size():
                slot.item = inventory.items[slot.slot_index]
            else:
                slot.item = null
            slot.update_display()

func _on_drop_requested(from: int, to: int) -> void:
    # Swap items between slots
    if from >= inventory.items.size() or to >= inventory.items.size():
        return
    var temp = inventory.items[from]
    inventory.items[from] = inventory.items[to]
    inventory.items[to] = temp
    refresh()
```

## Currency and Shop System

```gdscript
class_name EconomyManager extends Node

signal gold_changed(amount: int)
signal item_purchased(item: ItemData, cost: int)
signal item_sold(item: ItemData, price: int)

var gold: int = 0

func add_gold(amount: int) -> void:
    gold += amount
    gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
    if gold < amount:
        return false
    gold -= amount
    gold_changed.emit(gold)
    return true

# Shop transaction
func buy_item(inventory: Inventory, item_data: ItemData, price: int) -> bool:
    if not spend_gold(price):
        return false
    inventory.add_item(item_data)
    item_purchased.emit(item_data, price)
    return true

func sell_item(inventory: Inventory, item_index: int, price: int) -> bool:
    var inv_item = inventory.items[item_index]
    if not inv_item:
        return false
    inventory.remove_item(item_index, 1)
    add_gold(price)
    item_sold.emit(inv_item.item_data, price)
    return true
```

## Save Integration

Serialize inventory for save systems:

```gdscript
func serialize_inventory() -> Dictionary:
    var result = []
    for inv_item in items:
        result.append({
            "item_id": inv_item.item_data.item_id,
            "quantity": inv_item.quantity,
            "durability": inv_item.durability,
            "equipped": inv_item.is_equipped
        })
    return result

func deserialize_inventory(data: Array) -> void:
    items.clear()
    for entry in data:
        var item_data = load("res://items/" + entry["item_id"] + ".tres") as ItemData
        if item_data:
            var inv_item = InventoryItem.new()
            inv_item.item_data = item_data
            inv_item.quantity = entry["quantity"]
            inv_item.durability = entry.get("durability", 1.0)
            items.append(inv_item)
    inventory_changed.emit()
```

## Godot 4.7 Economy Notes

- **ResourceCache** — Preload item resources at game start for instant UI updates
- **tween_await()** — Animate gold counter changes or item pickup effects

## MCP Bridge Tools (Optional — Live Editor Integration)

When the MCP bridge is running (Phase 2), these tools can inspect and modify your project live:

- **`script_read`** / **`script_edit`** — Read and modify inventory scripts
- **`scene_tree`** — Inspect inventory UI node hierarchy

> **Note:** MCP tools require the Godot editor to be running with the MCP plugin enabled. Skills work independently without the bridge.

## References

- [Item Resource Design](references/item-resources.md)
- [Inventory UI Patterns](references/inventory-ui.md)
- [Economy Balance Guide](references/economy-balance.md)
