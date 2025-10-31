# Sistema de transición entre salas con condiciones flexibles
# Soporta llaves, flags, armas equipadas, y cualquier condición personalizada
extends Area2D

# ==================== CONFIGURACIÓN DE LA PUERTA ====================
@export var next_room_path: String = ""
@export var spawn_name: String = "SpawnPoint"

# ==================== TIPO DE BLOQUEO ====================
enum LockType {
	NONE,           # Sin bloqueo
	ITEM,           # Requiere un item específico
	FLAG,           # Requiere un flag del juego
	WEAPON,         # Requiere tener un arma equipada
	CUSTOM          # Condición personalizada
}

@export var lock_type: LockType = LockType.NONE

# ==================== PARÁMETROS SEGÚN EL TIPO ====================
@export var required_item: String = ""        # Para LockType.ITEM (ej: "llave_director")
@export var required_flag: String = ""        # Para LockType.FLAG (ej: "first_enemy_killed")
@export var custom_condition: String = ""     # Para LockType.CUSTOM (evaluado por GameState)

# ==================== MENSAJES ====================
@export var locked_message: String = "La puerta está cerrada."
@export var show_notification: bool = true    # Mostrar notificación en pantalla

# ==================== ESTADO ====================
var is_locked: bool = true
var was_unlocked_before: bool = false

# ==================== VISUAL FEEDBACK ====================
@onready var locked_sprite: Sprite2D = $LockedSprite  # Opcional: sprite de candado

func _ready() -> void:
	# Conectar señal
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Determinar si la puerta debe estar bloqueada
	update_lock_state()
	
	# Verificar si ya fue desbloqueada previamente
	check_previous_unlock()
	
	# Actualizar visual
	update_visual()

func _process(_delta: float) -> void:
	# Verificar constantemente si se cumplió la condición
	# (útil para puertas que se desbloquean por eventos)
	if is_locked:
		update_lock_state()

func update_lock_state() -> void:
	match lock_type:
		LockType.NONE:
			is_locked = false
		
		LockType.ITEM:
			is_locked = not GameState.has_item(required_item)
		
		LockType.FLAG:
			is_locked = not GameState.get_flag(required_flag)
		
		LockType.WEAPON:
			is_locked = not GameState.get_flag("has_weapon")
		
		LockType.CUSTOM:
			# Evaluar condición personalizada
			var parts = custom_condition.split(":")
			if parts.size() >= 2:
				is_locked = not GameState.check_condition(parts[0], parts[1])
			else:
				is_locked = not GameState.check_condition(custom_condition)
	
	# Si se desbloqueó, registrarlo
	if not is_locked and not was_unlocked_before:
		unlock()

func check_previous_unlock() -> void:
	var room_path = RoomManager.get_current_room_path()
	var door_id = name
	if GameState.is_door_unlocked(room_path, door_id):
		was_unlocked_before = true
		is_locked = false

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	# Si está bloqueada, mostrar mensaje y no hacer nada
	if is_locked:
		show_locked_notification()
		return
	
	# Si no está bloqueada, cargar la siguiente sala
	RoomManager.load_room(next_room_path, spawn_name)

func unlock() -> void:
	is_locked = false
	was_unlocked_before = true
	
	# Registrar desbloqueo en GameState
	var room_path = RoomManager.get_current_room_path()
	GameState.mark_door_unlocked(room_path, name)
	
	# Actualizar visual
	update_visual()
	
	print("✓ Puerta desbloqueada: ", name)

func set_unlocked(value: bool) -> void:
	is_locked = not value
	update_visual()

func update_visual() -> void:
	# Cambiar color del área para debug (verde = desbloqueado, rojo = bloqueado)
	modulate = Color.GREEN if not is_locked else Color.RED
	
	# Si tienes un sprite de candado, ocultarlo cuando está desbloqueado
	if locked_sprite:
		locked_sprite.visible = is_locked

func show_locked_notification() -> void:
	if not show_notification:
		return
	
	# Generar mensaje contextual según el tipo de bloqueo
	var message = locked_message
	
	if message.is_empty():
		match lock_type:
			LockType.ITEM:
				message = "Necesitas: " + required_item.replace("_", " ").capitalize()
			LockType.FLAG:
				message = "Debes cumplir cierta condición primero"
			LockType.WEAPON:
				message = "Necesitas un arma para continuar"
			LockType.CUSTOM:
				message = "No cumples los requisitos para pasar"
	
	print("🔒 ", message)
	# TODO: Implementar notificación visual en UI
	# UIManager.show_notification(message)

# ==================== DEBUG ====================
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if next_room_path.is_empty():
		warnings.append("No se ha configurado 'next_room_path'")
	
	if lock_type == LockType.ITEM and required_item.is_empty():
		warnings.append("Lock type es ITEM pero 'required_item' está vacío")
	
	if lock_type == LockType.FLAG and required_flag.is_empty():
		warnings.append("Lock type es FLAG pero 'required_flag' está vacío")
	
	if lock_type == LockType.CUSTOM and custom_condition.is_empty():
		warnings.append("Lock type es CUSTOM pero 'custom_condition' está vacío")
	
	return warnings
