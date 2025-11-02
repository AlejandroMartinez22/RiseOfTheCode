# Sistema de interacción del jugador
# Ahora también muestra mensajes de puertas bloqueadas
extends Node2D

@onready var interact_label: Label = $InteractLabel

var current_interactions := []
var can_interact := true
var door_message_active: bool = false  # Si hay un mensaje de puerta activo

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			interact_label.hide()
			
			await current_interactions[0].interact.call()
			
			can_interact = true

func _process(_delta: float) -> void:
	# Si hay un mensaje de puerta activo, tiene prioridad
	if door_message_active:
		return
	
	# Lógica normal de interacción con objetos
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sorts_by_nearest)
		
		if current_interactions[0].is_interactable:
			interact_label.text = current_interactions[0].interact_name
			interact_label.show()
		else:
			interact_label.hide()
	else:
		interact_label.hide()

func _sorts_by_nearest(area1, area2):
	var area1_distance = global_position.distance_to(area1.global_position)
	var area2_distance = global_position.distance_to(area2.global_position)
	return area1_distance < area2_distance

func _on_interact_range_area_entered(area: Area2D) -> void:
	if not area.name.to_lower().begins_with("exit"):
		current_interactions.push_back(area)

func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)

# ==================== MENSAJES DE PUERTAS ====================

# Muestra un mensaje de puerta bloqueada
func show_door_message(message: String) -> void:
	door_message_active = true
	interact_label.text = message
	interact_label.show()

# Oculta el mensaje de puerta
func hide_door_message() -> void:
	door_message_active = false
	interact_label.hide()
