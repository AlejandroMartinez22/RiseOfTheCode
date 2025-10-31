# Script para botón de Salir del Juego
extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	GameManager.quit_game()
