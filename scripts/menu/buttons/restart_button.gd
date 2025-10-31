# Script para botón de Reiniciar
extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	GameManager.restart_game()
