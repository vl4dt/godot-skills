## HUD overlay for lives and score.
## Demonstrates: CanvasLayer, signal-driven UI, and Label updates.

extends CanvasLayer

@onready var score_label := $MarginContainer/VBox/ScoreLabel
@onready var lives_label := $MarginContainer/VBox/LivesLabel
@onready var message_label := $MessageLabel

var _score: int = 0
var _lives: int = 3


func _ready() -> void:
	message_label.visible = false
	message_label.text = ""

	# Find and connect to player signals
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.died.connect(_on_player_died)


func _on_player_died() -> void:
	_lives -= 1
	_update_labels()

	if _lives <= 0:
		show_message("Game Over! Press R to restart", 3.0)
	else:
		show_message("Ouch!", 1.0)


func add_score(points: int) -> void:
	_score += points
	_update_labels()


func _update_labels() -> void:
	if score_label:
		score_label.text = "Score: " + str(_score)
	if lives_label:
		lives_label.text = "Lives: " + str(_lives)


func show_message(text: String, duration: float) -> void:
	if message_label:
		message_label.text = text
		message_label.visible = true

		var tween := create_tween()
		tween.tween_property(message_label, "modulate:a", 0.0, duration)
		await tween.finished
		message_label.visible = false
