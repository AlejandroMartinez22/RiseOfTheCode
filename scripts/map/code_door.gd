# code_door.gd
# Puerta que requiere código numérico para desbloquearse
# Una vez desbloqueada, funciona como SmartExit normal
extends "res://scripts/map/smart_exit.gd"

# ==================== CONFIGURACIÓN DEL CÓDIGO ====================
@export_group("Sistema de Código")
@export var door_id: String = ""  # ID único de la puerta
@export var correct_code: String = "1234"  # Código correcto
@export var keypad_ui_scene: PackedScene = null  # Escena del teclado numérico

# ==================== VARIABLES INTERNAS ====================
var keypad_instance: CanvasLayer = null
var code_was_entered: bool = false  # Flag para evitar múltiples verificaciones

func _ready() -> void:
	# Configurar como puerta bloqueada por defecto
	lock_type = LockType.CUSTOM
	
	# Auto-generar ID si no está configurado
	if door_id.is_empty():
		door_id = name
	
	# Verificar si ya fue desbloqueada previamente
	var room_path = RoomManager.get_current_room_path()
	if GameState.is_door_unlocked(room_path, door_id):
		# Ya está desbloqueada, comportarse como SmartExit normal
		lock_type = LockType.NONE
		is_locked = false
		was_unlocked_before = true
		print("✓ Puerta con código ya desbloqueada: ", door_id)
	else:
		# Aún bloqueada, requiere código
		is_locked = true
		print("🔒 Puerta con código bloqueada: ", door_id)
	
	# Llamar al _ready del padre (SmartExit)
	super._ready()

# Sobrescribir el comportamiento cuando el jugador entra al área
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_in_range = true
	
	# Si ya está desbloqueada, comportarse como SmartExit normal
	if not is_locked:
		# Transición automática (sin necesidad de presionar E)
		play_open_sound()
		RoomManager.call_deferred("load_room", next_room_path, spawn_name)
		return
	
	# Si está bloqueada, mostrar el teclado cuando presione E
	# No mostramos mensaje de "presiona E" aquí, lo manejamos en _input

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_in_range = false

# Detectar cuando el jugador presiona E para abrir el teclado
func _input(event: InputEvent) -> void:
	if not player_in_range or not is_locked:
		return
	
	if event.is_action_pressed("interact"):
		show_keypad()
		get_viewport().set_input_as_handled()

func show_keypad() -> void:
	if keypad_ui_scene == null:
		push_error("❌ No se configuró keypad_ui_scene para ", name)
		return
	
	# Reproducir sonido de puerta bloqueada
	if locked_sound:
		AudioManager.play_sound(locked_sound, global_position, -5.0)
	
	# Instanciar el teclado si no existe
	if keypad_instance == null:
		keypad_instance = keypad_ui_scene.instantiate()
		get_tree().root.add_child(keypad_instance)
		
		# Conectar señales
		if keypad_instance.has_signal("code_correct"):
			keypad_instance.connect("code_correct", Callable(self, "_on_code_correct"))
		if keypad_instance.has_signal("code_incorrect"):
			keypad_instance.connect("code_incorrect", Callable(self, "_on_code_incorrect"))
	
	# Mostrar el teclado con el código correcto
	if keypad_instance.has_method("show_keypad"):
		keypad_instance.show_keypad(correct_code)
		code_was_entered = false
	
	print("🔢 Mostrando teclado para puerta: ", door_id)

func _on_code_correct() -> void:
	if code_was_entered:
		return
	
	code_was_entered = true
	print("✅ Código correcto para puerta: ", door_id)
	
	# Reproducir sonido de desbloqueo
	#if unlock_sound:
		#AudioManager.play_sound(unlock_sound, global_position, 0.0)
	
	# Desbloquear la puerta permanentemente
	unlock_door_permanently()
	
	# El teclado se cierra automáticamente después de 2 segundos
	# (esto lo hace code_keypad_ui.gd)

func _on_code_incorrect() -> void:
	print("❌ Código incorrecto para puerta: ", door_id)

func unlock_door_permanently() -> void:
	is_locked = false
	was_unlocked_before = true
	
	# Registrar en GameState
	var room_path = RoomManager.get_current_room_path()
	GameState.mark_door_unlocked(room_path, door_id)
	
	# Actualizar visual
	update_visual()
	
	print("🔓 Puerta desbloqueada permanentemente: ", door_id)
	print("💡 Ahora funciona como puerta normal (sin presionar E)")

# ==================== DEBUG ====================
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if door_id.is_empty():
		warnings.append("Configura 'door_id' para identificar esta puerta")
	
	if correct_code.is_empty():
		warnings.append("Configura 'correct_code' con la contraseña")
	
	if next_room_path.is_empty():
		warnings.append("Configura 'next_room_path' con la sala de destino")
	
	if keypad_ui_scene == null:
		warnings.append("Asigna 'keypad_ui_scene' con la escena del teclado")
	
	return warnings
