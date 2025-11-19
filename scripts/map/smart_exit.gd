# Sistema de transición entre salas con condiciones flexibles
# Con sonidos simplificados: locked y open
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
@export var required_item: String = ""
@export var required_flag: String = ""
@export var custom_condition: String = ""

# ==================== MENSAJES ====================
@export var locked_message: String = "La puerta está cerrada."
@export var show_notification: bool = true

# ==================== SONIDOS (SIMPLIFICADO) ====================
@export_group("Sonidos")
@export var locked_sound: AudioStream = null   # Cuando intenta entrar bloqueado
@export var open_sound: AudioStream = null     # Cuando entra (desbloqueado)

# ==================== ESTADO ====================
var is_locked: bool = true
var was_unlocked_before: bool = false
var player_in_range: bool = false

# ==================== VISUAL FEEDBACK ====================
@onready var locked_sprite: Sprite2D = $LockedSprite if has_node("LockedSprite") else null

func _ready() -> void:
	# Conectar señales
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Determinar si la puerta debe estar bloqueada
	update_lock_state()
	
	# Verificar si ya fue desbloqueada previamente
	check_previous_unlock()
	
	# Actualizar visual
	update_visual()

func _process(_delta: float) -> void:
	# Verificar constantemente si se cumplió la condición
	if is_locked:
		var old_locked = is_locked
		update_lock_state()
		
		# Si se desbloqueó mientras el jugador está cerca, actualizar UI
		if old_locked and not is_locked and player_in_range:
			hide_door_notification()

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
	
	player_in_range = true
	
	# Si está bloqueada, mostrar mensaje y reproducir sonido
	if is_locked:
		show_door_notification()
		play_locked_sound()
		return
	
	# Si está desbloqueada, reproducir sonido y cambiar de sala
	play_open_sound()
	RoomManager.call_deferred("load_room", next_room_path, spawn_name)

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_in_range = false
	hide_door_notification()

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

# ==================== SONIDOS ====================

func play_locked_sound() -> void:
	if locked_sound:
		AudioManager.play_global_sound(locked_sound, -10.0)

func play_open_sound() -> void:
	if open_sound:
		AudioManager.play_global_sound(open_sound, -5.0)


# ==================== NOTIFICACIONES UI ====================

func show_door_notification() -> void:
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
	
	# Buscar el InteractingComponent del jugador y mostrar el mensaje
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var interact_comp = player.get_node_or_null("InteractingComponent")
		if interact_comp and interact_comp.has_method("show_door_message"):
			interact_comp.show_door_message(message)
	
	print("🔒 ", message)

func hide_door_notification() -> void:
	# Ocultar el mensaje cuando el jugador se aleja
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var interact_comp = player.get_node_or_null("InteractingComponent")
		if interact_comp and interact_comp.has_method("hide_door_message"):
			interact_comp.hide_door_message()

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
