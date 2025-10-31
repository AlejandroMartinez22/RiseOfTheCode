# Terminal interactiva que presenta puzzles de programación
# Con sistema de persistencia para recordar si ya fue resuelta
extends Area2D

# ==================== CONFIGURACIÓN ====================
@export var puzzle_id: String = ""                    # ID único del puzzle
@export var puzzle_ui_scene: PackedScene = null       # Escena de UI del puzzle
@export var reward_type: String = "door"              # "door", "item", "info"
@export var reward_target: String = ""                # ID de la puerta/item a desbloquear

# ==================== VISUAL ====================
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_prompt: Label = $InteractionPrompt  # Opcional: "Presiona E"

# ==================== ESTADO ====================
var is_solved: bool = false
var player_in_range: bool = false

func _ready() -> void:
	# Auto-generar ID si no está configurado
	if puzzle_id.is_empty():
		puzzle_id = name
	
	# Verificar si este puzzle ya fue resuelto
	var room_path = RoomManager.get_current_room_path()
	if GameState.is_puzzle_solved(room_path, puzzle_id):
		is_solved = true
		queue_free()  # Eliminarse si ya está resuelto
		return
	
	# Conectar señales
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Ocultar prompt inicialmente
	if interaction_prompt:
		interaction_prompt.visible = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		open_puzzle()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if interaction_prompt:
			interaction_prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if interaction_prompt:
			interaction_prompt.visible = false

func open_puzzle() -> void:
	if is_solved:
		return
	
	if puzzle_ui_scene == null:
		push_error("No se configuró puzzle_ui_scene para ", name)
		return
	
	# Instanciar la UI del puzzle
	var puzzle_ui = puzzle_ui_scene.instantiate()
	
	# Conectar señal de puzzle resuelto
	if puzzle_ui.has_signal("puzzle_solved"):
		puzzle_ui.connect("puzzle_solved", Callable(self, "_on_puzzle_solved"))
	
	# Agregar al árbol (debe ser hijo de un CanvasLayer)
	get_tree().root.add_child(puzzle_ui)
	
	# Pausar el juego mientras se resuelve el puzzle (opcional)
	# get_tree().paused = true

func _on_puzzle_solved() -> void:
	is_solved = true
	
	# Registrar puzzle como resuelto
	var room_path = RoomManager.get_current_room_path()
	GameState.mark_puzzle_solved(room_path, puzzle_id)
	
	# Otorgar recompensa
	grant_reward()
	
	# Despausar (si se pausó)
	# get_tree().paused = false
	
	# Eliminar la terminal del mundo
	queue_free()

func grant_reward() -> void:
	match reward_type:
		"door":
			# Desbloquear una puerta específica
			unlock_door(reward_target)
		
		"item":
			# Dar un item al jugador
			GameState.add_item(reward_target)
			print("✓ Item obtenido por puzzle: ", reward_target)
		
		"info":
			# Solo mostrar información narrativa
			print("✓ Puzzle resuelto: ", puzzle_id)
		
		"flag":
			# Activar un flag del juego
			GameState.set_flag(reward_target, true)
		
		_:
			print("✓ Puzzle resuelto sin recompensa específica")

func unlock_door(door_id: String) -> void:
	# Buscar la puerta en la sala actual
	var room = get_parent()
	var door = room.get_node_or_null(door_id)
	
	if door and door.has_method("unlock"):
		door.unlock()
		print("✓ Puerta desbloqueada: ", door_id)
	else:
		# Si no está en esta sala, registrarlo en GameState para cuando se cargue
		var room_path = RoomManager.get_current_room_path()
		GameState.mark_door_unlocked(room_path, door_id)

# ==================== DEBUG ====================
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if puzzle_ui_scene == null:
		warnings.append("No se ha configurado 'puzzle_ui_scene'")
	
	if reward_type in ["door", "item", "flag"] and reward_target.is_empty():
		warnings.append("'reward_target' está vacío pero se requiere para el tipo de recompensa")
	
	return warnings
