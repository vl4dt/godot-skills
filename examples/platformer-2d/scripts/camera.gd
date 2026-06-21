## Smooth follow camera.
## Demonstrates: Tween animations and smooth tracking.

extends Camera2D

@export var target: Node2D
@export var smoothing: float = 0.08


func _process(delta: float) -> void:
	if not target:
		return

	# Smooth interpolation toward target
	position.x = lerpf(position.x, target.position.x, smoothing)
	position.y = lerpf(position.y, target.position.y - 100.0, smoothing)
