# res://scenes/interactables/Interactable.gd
extends Area2D

@export var interact_name: String = "presiona E para leer"
@export var is_interactable: bool = true
@export var interact_type: String = "carta"  # "tablero" o "terminal"
@export var interact_text: String = "Texto por defecto para este objeto."

var interact: Callable = func():
	# Buscar UIManager en la escena actual (Main children). Esto es más robusto que get_root():
	var current_scene = get_tree().get_current_scene()
	if current_scene and current_scene.has_node("UIManager"):
		var ui_manager = current_scene.get_node("UIManager")
		ui_manager.show_ui(interact_type, interact_text)
	else:
		# Si no lo encuentra, intenta buscar en el root (fallback)
		var root = get_tree().get_root()
		if root.has_node("Main/UIManager"):
			var ui_manager2 = root.get_node("Main/UIManager")
			ui_manager2.show_ui(interact_type, interact_text)
		else:
			print("Interactable: no encontré UIManager para mostrar UI.")
