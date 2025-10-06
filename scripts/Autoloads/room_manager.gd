# Singleton que gestiona la carga y transición entre salas (niveles o habitaciones).
# Permite cambiar de sala sin recargar toda la escena principal del juego.
# Funciona en conjunto con el nodo principal "main", el cual contiene un nodo hijo
# llamado "CurrentRoom" que actúa como contenedor de la sala actual.

extends Node

var main_ref: Node = null # Referencia al nodo principal del juego ("main").
var current_room_instance: Node = null # Referencia a la instancia actual de la sala cargada.

# ------ Función: register_main --------

# Se llama desde main._ready() para registrar el nodo principal del juego.
# Esto permite al RoomManager acceder a "CurrentRoom" cuando se cargan salas.
func register_main(main_node: Node) -> void:
	main_ref = main_node

# ------ Función: load_room ---------

# Carga una nueva sala desde el path especificado y posiciona al jugador en el
# punto de aparición indicado.
# - path: ruta del archivo .tscn de la sala a cargar.
# - spawn_name: nombre del nodo dentro de la sala donde aparecerá el jugador.

func load_room(path: String, spawn_name: String = "RecepcionSpawn") -> void:
	
	# --- Validar referencia al nodo principal ---
	if main_ref == null:
		# Si no se registró manualmente, intentar obtenerlo desde el árbol de nodos.
		if get_tree().root.has_node("main"):
			main_ref = get_tree().root.get_node("main")
		else:
			push_error("RoomManager: main no registrado. Llama a RoomManager.register_main(main) en main._ready().")
			return

	# --- Buscar el contenedor de salas en el main ---
	var current_room = main_ref.get_node_or_null("CurrentRoom")
	if current_room == null:
		push_error("RoomManager: main no tiene un nodo hijo llamado 'CurrentRoom'.")
		return

	# --- Liberar la sala anterior (si existe) ---
	if current_room_instance:
		current_room_instance.queue_free()
		current_room_instance = null

	# --- Cargar la nueva sala ---
	var room_res = ResourceLoader.load(path)
	if room_res == null:
		push_error("RoomManager: no se pudo cargar la sala en %s" % path)
		return

	current_room_instance = room_res.instantiate()
	current_room.add_child(current_room_instance)

	# --- Reposicionar al jugador en el spawn indicado ---
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
