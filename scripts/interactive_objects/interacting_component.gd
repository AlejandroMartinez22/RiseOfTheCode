# InteractingComponent.gd (versión con debug)
extends Node2D

@onready var interact_label: Label = $InteractLabel
var current_interactions := []
var can_interact := true
var door_message_active: bool = false

func _ready() -> void:
	print("InteractingComponent inicializado")
	print("InteractLabel existe: ", interact_label != null)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("Tecla E presionada")
		print("can_interact: ", can_interact)
		print("current_interactions: ", current_interactions.size())
		
		if can_interact and current_interactions:
			can_interact = false
			interact_label.hide()
			
			print("Interactuando con: ", current_interactions[0].name)
			print("Tipo de interacción: ", current_interactions[0].interact_type)
			
			await current_interactions[0].interact.call()
			
			can_interact = true

func _process(_delta: float) -> void:
	if door_message_active:
		return
	
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
	print("Área detectada: ", area.name)
	if not area.name.to_lower().begins_with("exit"):
		current_interactions.push_back(area)
		print("Interactable agregado. Total: ", current_interactions.size())

func _on_interact_range_area_exited(area: Area2D) -> void:
	print("Área salida: ", area.name)
	current_interactions.erase(area)
	print("Interactables restantes: ", current_interactions.size())

func show_door_message(message: String) -> void:
	door_message_active = true
	interact_label.text = message
	interact_label.show()

func hide_door_message() -> void:
	door_message_active = false
	interact_label.hide()
