## Collectible item that can be picked up by the player.
## Demonstrates: Resource-based data, typed signals, and collision triggers.

class_name Collectible
extends Area2D

signal collected(item_name: String)

@export var item_name: String = "gem"
@export var quantity: int = 1
@onready var sprite := $Sprite2D
@onready var label := $Label


func _ready() -> void:
	# Collectibles on their own layer, detected by player
	collision_layer = 4  # collectible layer
	collision_mask = 1  # detect player

	if label:
		label.text = str(quantity) + "x " + item_name

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collected.emit(item_name)
		queue_free()
