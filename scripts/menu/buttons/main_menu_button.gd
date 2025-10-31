# Script para botón de Menú Principal
extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	GameManager.return_to_main_menu()
