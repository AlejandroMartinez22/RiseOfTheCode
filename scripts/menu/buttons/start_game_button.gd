# Script para botón de Iniciar Juego
extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	GameManager.start_new_game()
