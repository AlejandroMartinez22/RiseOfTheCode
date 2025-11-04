# interactable.gd (versión con debug)
extends Area2D

@export var interact_name: String = "presiona E para leer"
@export var is_interactable: bool = true
@export var interact_type: String = "carta"
@export var interact_text: String = "Texto por defecto"

var interact: Callable = func():
	print("Callable de interact ejecutado")
	var main = get_tree().get_current_scene()
	print("Main encontrado: ", main != null)
	
	if main and main.has_node("CanvasLayer"):
		print("CanvasLayer encontrado")
		var ui_manager = main.get_node("UImanager")
		print("UIManager obtenido: ", ui_manager != null)
		print("Llamando show_ui con tipo: ", interact_type)
		ui_manager.show_ui(interact_type, interact_text)
	else:
		print("ERROR: No se encontró CanvasLayer en Main")
