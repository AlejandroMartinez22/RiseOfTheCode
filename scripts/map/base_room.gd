# Script base para todas las salas del juego
# Adjunta este script a cada escena de sala (recepción, biblioteca, pasillos, etc.)
extends Node2D

# Este será el path único de la sala (se auto-detecta)
var room_path: String = ""

func _ready() -> void:
	# Auto-detectar el path de esta escena
	room_path = scene_file_path
	
	# La restauración se llamará desde RoomManager después de _ready
	# No la llamamos aquí para evitar problemas de timing

# Esta función es llamada por RoomManager después de que la sala se carga
func restore_state() -> void:
	var state = GameState.get_room_state(room_path)
	
	# 1. Eliminar enemigos que ya fueron matados
	restore_enemies(state["enemies_killed"])
	
	# 2. Eliminar objetos que ya fueron recogidos
	restore_items(state["items_collected"])
	
	# 3. Mantener puertas desbloqueadas
	restore_doors(state["doors_unlocked"])
	
	# 4. Eliminar puzzles que ya fueron resueltos
	restore_puzzles(state["puzzles_solved"])
	
	print("Estado restaurado para sala: ", room_path)

# Restaurar enemigos (eliminar los que ya fueron matados)
func restore_enemies(killed_list: Array) -> void:
	for enemy_id in killed_list:
		var enemy = get_node_or_null(enemy_id)
		if enemy:
			enemy.queue_free()

# Restaurar items (eliminar los que ya fueron recogidos)
func restore_items(collected_list: Array) -> void:
	for item_id in collected_list:
		var item = get_node_or_null(item_id)
		if item:
			item.queue_free()

# Restaurar puertas (mantener desbloqueadas las que ya se abrieron)
func restore_doors(unlocked_list: Array) -> void:
	for door_id in unlocked_list:
		var door = get_node_or_null(door_id)
		if door and door.has_method("set_unlocked"):
			door.set_unlocked(true)

# Restaurar puzzles (eliminar los que ya fueron resueltos)
func restore_puzzles(solved_list: Array) -> void:
	for puzzle_id in solved_list:
		var puzzle = get_node_or_null(puzzle_id)
		if puzzle:
			puzzle.queue_free()
