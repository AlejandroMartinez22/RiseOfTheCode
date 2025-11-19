# Singleton que maneja TODO el estado persistente del juego
# Reemplaza y extiende el concepto de RoomState
extends Node

# ==================== ESTADO DE SALAS ====================
# Estructura: { "ruta_sala": { "enemies_killed": [...], "items_collected": [...], ... } }
var room_states: Dictionary = {}

# ==================== INVENTARIO Y FLAGS ====================
# Objetos que el jugador ha obtenido
var inventory: Dictionary = {
	"laser_gun": false,
	"rifle_asalto": false,
	"llave_director": false,
	"llave_lab_ciencias": false,
	"llave_lab_robotica": false,
	"acido_quimico": false
}

# Flags de eventos del juego (cosas que han pasado)
var game_flags: Dictionary = {
	"has_weapon": false,              # El jugador tiene algún arma equipada
	"tutorial_completed": false,      # Completó el tutorial
	"first_enemy_killed": false,      # Mató su primer enemigo
	"library_unlocked": false,        # Desbloqueó la biblioteca
	"boss_defeated": false,           # Derrotó al jefe final
	"entered_salon_101": false        # Entró al salón 101 (para poder entrar al 202)
}

# ==================== FUNCIONES DE ESTADO DE SALA ====================

func get_room_state(room_path: String) -> Dictionary:
	if not room_states.has(room_path):
		room_states[room_path] = {
			"enemies_killed": [],   # IDs de enemigos eliminados
			"items_collected": [],  # IDs de objetos recogidos
			"puzzles_solved": [],   # IDs de puzzles resueltos
			"doors_unlocked": [],   # IDs de puertas desbloqueadas
			"events_triggered": []  # Eventos únicos de esta sala
		}
	return room_states[room_path]

# ==================== ENEMIGOS ====================

func mark_enemy_killed(room_path: String, enemy_id: String) -> void:
	var state = get_room_state(room_path)
	if enemy_id not in state["enemies_killed"]:
		state["enemies_killed"].append(enemy_id)
		
	# Actualizar flag de primer enemigo matado
	if not game_flags["first_enemy_killed"]:
		game_flags["first_enemy_killed"] = true
		print("¡Primer enemigo eliminado!")

func is_enemy_killed(room_path: String, enemy_id: String) -> bool:
	var state = get_room_state(room_path)
	return enemy_id in state["enemies_killed"]

# ==================== OBJETOS/ITEMS ====================

func mark_item_collected(room_path: String, item_id: String) -> void:
	var state = get_room_state(room_path)
	if item_id not in state["items_collected"]:
		state["items_collected"].append(item_id)

func is_item_collected(room_path: String, item_id: String) -> bool:
	var state = get_room_state(room_path)
	return item_id in state["items_collected"]

# ==================== PUZZLES ====================

func mark_puzzle_solved(room_path: String, puzzle_id: String) -> void:
	var state = get_room_state(room_path)
	if puzzle_id not in state["puzzles_solved"]:
		state["puzzles_solved"].append(puzzle_id)
		print("Puzzle resuelto: ", puzzle_id)

func is_puzzle_solved(room_path: String, puzzle_id: String) -> bool:
	var state = get_room_state(room_path)
	return puzzle_id in state["puzzles_solved"]

# ==================== PUERTAS ====================

func mark_door_unlocked(room_path: String, door_id: String) -> void:
	var state = get_room_state(room_path)
	if door_id not in state["doors_unlocked"]:
		state["doors_unlocked"].append(door_id)

func is_door_unlocked(room_path: String, door_id: String) -> bool:
	var state = get_room_state(room_path)
	return door_id in state["doors_unlocked"]

# ==================== INVENTARIO ====================

func has_item(item_key: String) -> bool:
	return inventory.get(item_key, false)

func add_item(item_key: String) -> void:
	inventory[item_key] = true
	print("✓ Item añadido: ", item_key)
	
	# Actualizar flags relacionados
	if item_key in ["laser_gun", "rifle_asalto"]:
		game_flags["has_weapon"] = true

func remove_item(item_key: String) -> void:
	inventory[item_key] = false

# ==================== GAME FLAGS ====================

func set_flag(flag_name: String, value: bool = true) -> void:
	if flag_name in game_flags:
		game_flags[flag_name] = value
		print("Flag actualizado: ", flag_name, " = ", value)
	else:
		push_warning("Flag no existe: ", flag_name)

func get_flag(flag_name: String) -> bool:
	return game_flags.get(flag_name, false)

# ==================== EVENTOS DE SALA ====================

func trigger_event(room_path: String, event_id: String) -> void:
	var state = get_room_state(room_path)
	if event_id not in state["events_triggered"]:
		state["events_triggered"].append(event_id)

func is_event_triggered(room_path: String, event_id: String) -> bool:
	var state = get_room_state(room_path)
	return event_id in state["events_triggered"]

# ==================== CONDICIONES PERSONALIZADAS ====================
# Sistema flexible para evaluar cualquier condición del juego

func check_condition(condition_type: String, condition_value: String = "") -> bool:
	match condition_type:
		"has_item":
			return has_item(condition_value)
		
		"has_flag":
			return get_flag(condition_value)
		
		"has_weapon":
			return game_flags["has_weapon"]
		
		"puzzle_solved":
			var parts = condition_value.split(":")
			if parts.size() == 2:
				return is_puzzle_solved(parts[0], parts[1])
			return false
		
		"enemies_cleared":
			# Verifica si todos los enemigos de una sala fueron eliminados
			var room_path = condition_value
			var state = get_room_state(room_path)
			# Esto requeriría conocer cuántos enemigos hay originalmente
			# Por ahora, retorna true si al menos 1 enemigo fue matado
			return state["enemies_killed"].size() > 0
		
		"always":
			return true
		
		"never":
			return false
		
		_:
			push_warning("Condición desconocida: ", condition_type)
			return false

# ==================== RESET ====================

func reset() -> void:
	room_states.clear()
	pending_spawns.clear()
	
	inventory = {
		"laser_gun": false,
		"rifle_asalto": false,
		"llave_director": false,
		"llave_lab_ciencias": false,
		"llave_lab_robotica": false,
		"acido_quimico": false
	}
	
	game_flags = {
		"has_weapon": false,
		"tutorial_completed": false,
		"first_enemy_killed": false,
		"library_unlocked": false,
		"boss_defeated": false,
		"entered_salon_101": false
	}
	
	print("Estado del juego reseteado")

# ==================== DEBUG ====================

func print_state() -> void:
	print("=== ESTADO DEL JUEGO ===")
	print("Inventario: ", inventory)
	print("Flags: ", game_flags)
	print("Salas visitadas: ", room_states.keys().size())
	
	
	
	# ==================== SISTEMA DE SPAWNS PENDIENTES ====================
var pending_spawns: Dictionary = {}
# Estructura: { "room_path": [ {scene, position, enemy_id}, ... ] }

func register_pending_spawn(room_path: String, enemy_scene: PackedScene, position: Vector2, enemy_id: String) -> void:
	if not pending_spawns.has(room_path):
		pending_spawns[room_path] = []
	
	# Evitar duplicados
	for spawn in pending_spawns[room_path]:
		if spawn["enemy_id"] == enemy_id:
			print("⚠️ Spawn ya registrado: ", enemy_id)
			return
	
	pending_spawns[room_path].append({
		"scene": enemy_scene,
		"position": position,
		"enemy_id": enemy_id
	})
	
	print("📝 Spawn registrado para ", room_path, ": ", enemy_id)

func get_pending_spawns(room_path: String) -> Array:
	return pending_spawns.get(room_path, [])
