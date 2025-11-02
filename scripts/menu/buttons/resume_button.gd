# Script para botón de Reanudar
extends Button

@onready var audio_player = $AudioStreamPlayer

func _ready() -> void:
	pressed.connect(_on_pressed)
	focus_mode = Control.FOCUS_NONE

func _on_pressed() -> void:
	if audio_player and audio_player.stream:
		audio_player.play()
		# Esperar a que termine el sonido
		await audio_player.finished
	GameManager.resume_game()
