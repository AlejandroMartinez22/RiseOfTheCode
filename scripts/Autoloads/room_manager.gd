extends Node

var main_ref: Node = null
var current_room_instance: Node = null

# Se llama desde main._ready()
func register_main(main_node: Node) -> void:
	main_ref = main_node

func load_room(path: String, spawn_name: String = "RecepcionSpawn") -> void:
	
	# --- Validar referencia a main ---
	if main_ref == null:
		if get_tree().root.has_node("main"):
			main_ref = get_tree().root.get_node("main")
		else:
			push_error("RoomManager: main no registrado. Llama a RoomManager.register_main(main) en main._ready().")
			return

	# --- Buscar contenedor de salas ---
	var current_room = main_ref.get_node_or_null("CurrentRoom")
	if current_room == null:
		push_error("RoomManager: main no tiene un child llamado 'CurrentRoom'.")
		return

	# --- Limpiar sala anterior ---
	if current_room_instance:
		current_room_instance.queue_free()
		current_room_instance = null

	# --- Cargar nueva sala ---
	var room_res = ResourceLoader.load(path)
	if room_res == null:
		push_error("RoomManager: no se pudo cargar la sala en %s" % path)
		return

	current_room_instance = room_res.instantiate()
	current_room.add_child(current_room_instance)

	# --- Reposicionar jugador en el spawn ---
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var spawn = current_room_instance.get_node_or_null(spawn_name)

		if spawn:
			player.global_position = spawn.global_position
		else:
			push_warning("RoomManager: la sala no tiene un nodo '%s'. El jugador no se reposicionó." % spawn_name)
	else:
		push_warning("RoomManager: no se encontró ningún nodo en el grupo 'player'.")
