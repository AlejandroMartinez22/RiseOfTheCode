extends Button

@onready var audio_player = $AudioStreamPlayer
@onready var transition = preload("res://scenes/menu/transition.tscn")

func _ready() -> void:
	pressed.connect(_on_pressed)
	focus_mode = Control.FOCUS_NONE

func _on_pressed() -> void:
	if audio_player and audio_player.stream:
		audio_player.play()
		await audio_player.finished

	transition.instantiate()
	GameManager.start_new_game()
