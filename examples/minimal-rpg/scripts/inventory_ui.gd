## Inventory UI panel for displaying collected items.
## Demonstrates: Container layout, Resource-based inventory management,
## and signal-driven UI updates.

class_name InventoryUI
extends PanelContainer

@export var slot_container: VBoxContainer
@onready var count_label := $VBoxContainer/ItemCountLabel

var _inventory: Dictionary = {}


func _ready() -> void:
	# Find player and connect signals
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.item_collected.connect(_on_item_collected)

	visibility_changed.connect(_on_visibility_changed)


func _on_item_collected(item_name: String, quantity: int) -> void:
	_inventory[item_name] = _inventory.get(item_name, 0) + quantity
	_update_display()


func _update_display() -> void:
	if count_label:
		var total := 0
		for item in _inventory.values():
			total += item
		count_label.text = "Items: " + str(total)

	# Update individual slots
	for child in slot_container.get_children():
		if child is Label:
			child.queue_free()

	for item_name in _inventory:
		var label := Label.new()
		label.text = item_name.capitalize() + ": " + str(_inventory[item_name])
		slot_container.add_child(label)


func _on_visibility_changed() -> void:
	if not visible:
		return  # Only update when visible
