# InteractingComponent.gd
# Sistema de interacción del jugador con objetos del mundo
extends Node2D

@onready var interact_label: Label = $InteractLabel
var current_interactions := []
var can_interact := true
var door_message_active: bool = false
var temporary_message_active: bool = false

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
			
			var closest = current_interactions[0]
			print("Interactuando con: ", closest.name)
			
			# Ejecutar el callable "interact" del objeto
			if closest.get("interact") != null and closest.interact is Callable:
				print("Ejecutando interact callable")
				await closest.interact.call()
			else:
				print("⚠️ El objeto no tiene callable 'interact'")
			
			can_interact = true

func _process(_delta: float) -> void:
	if door_message_active or temporary_message_active:
		return
	
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sorts_by_nearest)
		
		var closest = current_interactions[0]
		
		# Verificar si es interactuable (lo importante)
		var is_interactable_obj = closest.get("is_interactable")
		if is_interactable_obj != null and is_interactable_obj:
			# Mostrar el mensaje apropiado
			var interact_name = closest.get("interact_name")
			if interact_name != null:
				interact_label.text = interact_name
			else:
				interact_label.text = "E para interactuar"
			
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

# ==================== MENSAJES DE PUERTAS ====================

func show_door_message(message: String) -> void:
	door_message_active = true
	interact_label.text = message
	interact_label.show()

func hide_door_message() -> void:
	door_message_active = false
	interact_label.hide()

# ==================== MENSAJES TEMPORALES ====================

func show_temporary_message(message: String, duration: float = 3.0) -> void:
	temporary_message_active = true
	interact_label.text = message
	interact_label.show()
	
	print("💬 ", message)
	
	# Crear timer para ocultar el mensaje
	await get_tree().create_timer(duration).timeout
	
	temporary_message_active = false
	interact_label.hide()
