# Singleton mejorado para gestión de salas con persistencia de estado
extends Node

var main_ref: Node = null
var current_room_instance: Node = null
var current_room_path: String = ""

func register_main(main_node: Node) -> void:
	main_ref = main_node

func load_room(path: String, spawn_name: String = "MainSpawn") -> void:
	
	# Validar referencia al nodo principal
	if main_ref == null:
		if get_tree().root.has_node("main"):
			main_ref = get_tree().root.get_node("main")
		else:
			push_error("RoomManager: main no registrado.")
			return
	
	# Buscar el contenedor de salas
	var current_room = main_ref.get_node_or_null("CurrentRoom")
	if current_room == null:
		push_error("RoomManager: main no tiene un nodo hijo llamado 'CurrentRoom'.")
		return
	
	# Liberar la sala anterior
	if current_room_instance:
		current_room_instance.queue_free()
		current_room_instance = null
	
	# Actualizar el path de la sala actual
	current_room_path = path
	
	# Cargar la nueva sala
	var room_res = ResourceLoader.load(path)
	if room_res == null:
		push_error("RoomManager: no se pudo cargar la sala en %s" % path)
		return
	
	# NUEVO: Verificar que sea un PackedScene válido
	if not room_res is PackedScene:
		push_error("RoomManager: el recurso cargado no es un PackedScene")
		return
	
	current_room_instance = room_res.instantiate()
	
	# NUEVO: Verificar que la instancia se creó correctamente
	if current_room_instance == null:
		push_error("RoomManager: no se pudo instanciar la sala")
		return
	
	current_room.add_child(current_room_instance)
	
	# Esperar a que la sala esté completamente inicializada
	await get_tree().process_frame
	
	# Restaurar el estado de la sala si tiene el método
	if current_room_instance.has_method("restore_state"):
		current_room_instance.restore_state()
	
	# Reposicionar al jugador
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var spawn = current_room_instance.get_node_or_null(spawn_name)
		if spawn:
			player.global_position = spawn.global_position
		else:
			push_warning("RoomManager: la sala no tiene un nodo '%s'." % spawn_name)
	else:
		push_warning("RoomManager: no se encontró ningún nodo en el grupo 'player'.")

func get_current_room_path() -> String:
	return current_room_path
