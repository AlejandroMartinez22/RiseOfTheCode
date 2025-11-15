# puzzle_terminal.gd
# Terminal interactiva con puzzles basados en imágenes
# Soporta recompensas: items, spawn de objetos, ocultar tilemaps, spawn de enemigos
extends Area2D

# ==================== CONFIGURACIÓN BÁSICA ====================
@export_group("Identificación")
@export var puzzle_id: String = ""
@export var interact_name: String = "Presiona E para interactuar"

# ==================== PUZZLE UI ====================
@export_group("Configuración de Puzzle")
@export var puzzle_ui_scene: PackedScene = null

# ==================== DATOS DEL PUZZLE ====================
@export_group("Configuración del Puzzle (Script)")
@export_file("*.gd") var puzzle_config_script: String = ""

# ==================== RECOMPENSAS ====================
@export_group("Recompensas")
@export var give_item: bool = false
@export var reward_item_key: String = ""

@export var spawn_object: bool = false
@export var object_to_spawn: PackedScene = null
@export var spawn_position: Vector2 = Vector2.ZERO
@export var spawn_object_id: String = ""

@export var unlock_door: bool = false
@export var door_to_unlock: String = ""

@export var hide_tilemap: bool = false
@export var tilemap_layer_to_hide: String = ""

@export var spawn_enemies: bool = false
@export var enemies_to_spawn: Array[Dictionary] = []
# Formato: [
#   {"scene": PackedScene, "room_path": "res://...", "position": Vector2(x, y), "enemy_id": "centinela_01"}
# ]

# ==================== ESTADO ====================
var is_solved: bool = false
var player_in_range: bool = false
var puzzle_ui_instance: CanvasLayer = null
var is_interactable: bool = true

# ==================== CALLABLE ====================
var interact: Callable = func():
	if is_interactable and not is_solved:
		open_puzzle()

func _ready() -> void:
	# Configurar capas de colisión
	collision_layer = 32  # Capa 6
	collision_mask = 0
	
	# Auto-generar ID si no está configurado
	if puzzle_id.is_empty():
		puzzle_id = name
	
	# Verificar si este puzzle ya fue resuelto
	var room_path = RoomManager.get_current_room_path()
	if GameState.is_puzzle_solved(room_path, puzzle_id):
		is_solved = true
		is_interactable = false
		print("✓ Puzzle ya resuelto: ", puzzle_id)
		return
	
	# Conectar señales
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))
	
	print("🧩 PuzzleTerminal listo: ", puzzle_id)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not is_solved:
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func open_puzzle() -> void:
	if is_solved or puzzle_ui_scene == null:
		return
	
	# Instanciar la UI del puzzle si no existe
	if puzzle_ui_instance == null:
		puzzle_ui_instance = puzzle_ui_scene.instantiate()
		get_tree().root.add_child(puzzle_ui_instance)
		
		# Conectar señales
		if puzzle_ui_instance.has_signal("puzzle_solved"):
			puzzle_ui_instance.connect("puzzle_solved", Callable(self, "_on_puzzle_solved"))
	
	# Cargar datos del puzzle desde script externo
	var puzzle_data: Dictionary
	
	if not puzzle_config_script.is_empty():
		var config_script = load(puzzle_config_script)
		if config_script and config_script.has_method("get_puzzle_data"):
			puzzle_data = config_script.get_puzzle_data()
			print("✅ Configuración cargada desde script: ", puzzle_config_script)
		else:
			push_error("❌ El script no tiene el método get_puzzle_data()")
			return
	else:
		push_error("❌ No se configuró puzzle_config_script")
		return
	
	# Mostrar puzzle
	if puzzle_ui_instance.has_method("show_puzzle"):
		puzzle_ui_instance.show_puzzle(puzzle_data)
	
	print("🖥️ Puzzle abierto: ", puzzle_id)

func _on_puzzle_solved() -> void:
	is_solved = true
	is_interactable = false
	
	# Registrar puzzle como resuelto
	var room_path = RoomManager.get_current_room_path()
	GameState.mark_puzzle_solved(room_path, puzzle_id)
	
	# Otorgar todas las recompensas configuradas
	grant_all_rewards()
	
	print("✅ Puzzle resuelto: ", puzzle_id)

# ==================== SISTEMA DE RECOMPENSAS ====================
func grant_all_rewards() -> void:
	if give_item and not reward_item_key.is_empty():
		grant_item_reward()
	
	if spawn_object and object_to_spawn != null:
		grant_spawn_object_reward()
	
	if unlock_door and not door_to_unlock.is_empty():
		grant_unlock_door_reward()
	
	if hide_tilemap and not tilemap_layer_to_hide.is_empty():
		grant_hide_tilemap_reward()
	
	if spawn_enemies and not enemies_to_spawn.is_empty():
		grant_spawn_enemies_reward()

# ==================== RECOMPENSA: DAR ITEM ====================
func grant_item_reward() -> void:
	GameState.add_item(reward_item_key)
	show_message("Has obtenido: " + reward_item_key.replace("_", " ").capitalize())
	print("✓ Item otorgado: ", reward_item_key)

# ==================== RECOMPENSA: SPAWN OBJECT ====================
func grant_spawn_object_reward() -> void:
	# Verificar si ya fue instanciado antes
	if not spawn_object_id.is_empty():
		var room_path = RoomManager.get_current_room_path()
		if GameState.is_item_collected(room_path, spawn_object_id):
			print("⚠️ Objeto ya fue instanciado: ", spawn_object_id)
			return
	
	# Instanciar objeto
	var obj = object_to_spawn.instantiate()
	
	# Si tiene posición configurada, usarla
	if spawn_position != Vector2.ZERO:
		obj.global_position = spawn_position
	else:
		obj.global_position = global_position
	
	# Agregar a la escena
	get_parent().add_child(obj)
	
	# Marcar como instanciado si tiene ID
	if not spawn_object_id.is_empty():
		var room_path = RoomManager.get_current_room_path()
		GameState.mark_item_collected(room_path, spawn_object_id)
	
	print("✓ Objeto instanciado: ", obj.name, " en ", spawn_position)

# ==================== RECOMPENSA: UNLOCK DOOR ====================
func grant_unlock_door_reward() -> void:
	var room_path = RoomManager.get_current_room_path()
	var door = get_parent().get_node_or_null(door_to_unlock)
	
	if door and door.has_method("unlock"):
		door.unlock()
		print("✓ Puerta desbloqueada: ", door_to_unlock)
	else:
		GameState.mark_door_unlocked(room_path, door_to_unlock)
		print("✓ Puerta marcada como desbloqueada: ", door_to_unlock)

# ==================== RECOMPENSA: HIDE TILEMAP ====================
func grant_hide_tilemap_reward() -> void:
	var root = get_tree().current_scene
	var tilemap_layer = root.find_child(tilemap_layer_to_hide, true, false)
	
	if tilemap_layer and tilemap_layer is TileMapLayer:
		tilemap_layer.visible = false
		print("✓ TileMapLayer ocultado: ", tilemap_layer_to_hide)
	else:
		push_warning("⚠️ No se encontró TileMapLayer: ", tilemap_layer_to_hide)

# ==================== RECOMPENSA: SPAWN ENEMIES ====================
func grant_spawn_enemies_reward() -> void:
	for enemy_data in enemies_to_spawn:
		spawn_enemy_from_data(enemy_data)

func spawn_enemy_from_data(data: Dictionary) -> void:
	var enemy_scene: PackedScene = data.get("scene")
	var room_path: String = data.get("room_path", "")
	var pos: Vector2 = data.get("position", Vector2.ZERO)
	var enemy_id: String = data.get("enemy_id", "")
	
	if enemy_scene == null:
		push_error("❌ Enemy scene no configurado en spawn_enemies")
		return
	
	# Auto-generar ID si no está configurado
	if enemy_id.is_empty():
		enemy_id = "enemy_" + str(randi())
		print("⚠️ Generando ID automático para enemigo: ", enemy_id)
	
	# Si no hay room_path, instanciar en la sala actual
	if room_path.is_empty():
		instantiate_enemy_here(enemy_scene, pos, enemy_id)
	else:
		# Registrar para instanciar cuando se cargue esa sala
		register_enemy_for_room(enemy_scene, room_path, pos, enemy_id)

func instantiate_enemy_here(enemy_scene: PackedScene, pos: Vector2, enemy_id: String) -> void:
	var room_path = RoomManager.get_current_room_path()
	
	# Verificar si el enemigo ya fue eliminado
	if GameState.is_enemy_killed(room_path, enemy_id):
		print("⚠️ Enemigo ya eliminado: ", enemy_id)
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Configurar ID
	if enemy.has("enemy_id"):
		enemy.enemy_id = enemy_id
	
	# Posicionar
	enemy.global_position = pos if pos != Vector2.ZERO else global_position
	
	# Agregar a la escena
	get_parent().add_child(enemy)
	
	print("✓ Enemigo instanciado: ", enemy_id, " en ", pos)

func register_enemy_for_room(enemy_scene: PackedScene, room_path: String, pos: Vector2, enemy_id: String) -> void:
	# Registrar en GameState para instanciar cuando se cargue la sala
	GameState.register_pending_spawn(room_path, enemy_scene, pos, enemy_id)
	print("📝 Enemigo registrado para sala: ", room_path, " | ID: ", enemy_id)

# ==================== UTILIDADES ====================
func show_message(message: String) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var interact_comp = player.get_node_or_null("InteractingComponent")
		if interact_comp and interact_comp.has_method("show_temporary_message"):
			interact_comp.show_temporary_message(message, 3.0)

# ==================== DEBUG ====================
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if puzzle_ui_scene == null:
		warnings.append("No se ha configurado 'puzzle_ui_scene'")
	
	if puzzle_config_script.is_empty():
		warnings.append("Debes configurar 'puzzle_config_script'")
	
	if spawn_object and object_to_spawn == null:
		warnings.append("'spawn_object' está habilitado pero 'object_to_spawn' está vacío")
	
	if spawn_enemies and enemies_to_spawn.is_empty():
		warnings.append("'spawn_enemies' está habilitado pero 'enemies_to_spawn' está vacío")
	
	if give_item and reward_item_key.is_empty():
		warnings.append("'give_item' está habilitado pero 'reward_item_key' está vacío")
	
	return warnings
