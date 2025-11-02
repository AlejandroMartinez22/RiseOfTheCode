# Script base para todas las salas del juego
# Ahora con soporte para límites de cámara
extends Node2D

var room_path: String = ""

func _ready() -> void:
	# Auto-detectar el path de esta escena
	room_path = scene_file_path
	
	# Aplicar límites de cámara si existen
	apply_camera_bounds()

# Esta función es llamada por RoomManager después de que la sala se carga
func restore_state() -> void:
	var state = GameState.get_room_state(room_path)
	
	# Restaurar estado normal
	restore_enemies(state["enemies_killed"])
	restore_items(state["items_collected"])
	restore_doors(state["doors_unlocked"])
	restore_puzzles(state["puzzles_solved"])
	
	# Replicar límites de cámara (por si acaso)
	apply_camera_bounds()
	
	print("Estado restaurado para sala: ", room_path)

# Aplica los límites de cámara definidos en esta sala
func apply_camera_bounds() -> void:
	# Buscar un nodo CameraBounds en esta sala
	var camera_bounds = find_child_by_class("CameraBounds")
	
	if camera_bounds and camera_bounds.has_method("apply_bounds_to_camera"):
		camera_bounds.apply_bounds_to_camera()
	else:
		# Si no hay CameraBounds, buscar CameraZones
		var zones = get_children().filter(func(child): return child is CameraZone)
		if zones.size() > 0:
			print("📷 Sala con %d CameraZones" % zones.size())
		else:
			print("⚠️ Sala sin límites de cámara definidos")

# Busca un hijo por nombre de clase
func find_child_by_class(class_name: String) -> Node:
	for child in get_children():
		if child.get_class() == class_name or (child.get_script() and child.get_script().get_global_name() == class_name):
			return child
	return null

# Funciones de restauración (sin cambios)
func restore_enemies(killed_list: Array) -> void:
	for enemy_id in killed_list:
		var enemy = get_node_or_null(enemy_id)
		if enemy:
			enemy.queue_free()

func restore_items(collected_list: Array) -> void:
	for item_id in collected_list:
		var item = get_node_or_null(item_id)
		if item:
			item.queue_free()

func restore_doors(unlocked_list: Array) -> void:
	for door_id in unlocked_list:
		var door = get_node_or_null(door_id)
		if door and door.has_method("set_unlocked"):
			door.set_unlocked(true)

func restore_puzzles(solved_list: Array) -> void:
	for puzzle_id in solved_list:
		var puzzle = get_node_or_null(puzzle_id)
		if puzzle:
			puzzle.queue_free()
