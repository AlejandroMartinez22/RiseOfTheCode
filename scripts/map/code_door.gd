# code_door.gd
# Puerta que requiere código numérico para desbloquearse
# Una vez desbloqueada, permite paso automático con sonido
extends Area2D

# ==================== CONFIGURACIÓN BÁSICA ====================
@export_group("Configuración de Sala")
@export var next_room_path: String = ""
@export var spawn_name: String = "SpawnPoint"

# ==================== CONFIGURACIÓN DEL CÓDIGO ====================
@export_group("Sistema de Código")
@export var door_id: String = ""  # ID único de la puerta
@export var correct_code: String = "1234"  # Código correcto
@export var keypad_ui_scene: PackedScene = null  # Escena del teclado numérico

# ==================== SONIDOS ====================
@export_group("Sonidos")
@export var open_sound: AudioStream = null  # Cuando pasa (desbloqueada)

# ==================== MENSAJES ====================
@export_group("Mensajes")
@export var show_notification: bool = true

# ==================== VARIABLES INTERNAS ====================
var is_locked: bool = true
var was_unlocked_before: bool = false
var player_in_range: bool = false
var keypad_instance: CanvasLayer = null
var code_was_entered: bool = false

# ==================== VISUAL FEEDBACK ====================
@onready var locked_sprite: Sprite2D = $LockedSprite if has_node("LockedSprite") else null

func _ready() -> void:
	# Auto-generar ID si no está configurado
	if door_id.is_empty():
		door_id = name
	
	# Verificar si ya fue desbloqueada previamente
	var room_path = RoomManager.get_current_room_path()
	if GameState.is_door_unlocked(room_path, door_id):
		# Ya está desbloqueada
		is_locked = false
		was_unlocked_before = true
		print("✓ Puerta con código ya desbloqueada: ", door_id)
	else:
		# Aún bloqueada
		is_locked = true
		print("🔒 Puerta con código bloqueada: ", door_id)
	
	# Conectar señales
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Actualizar visual
	update_visual()

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_in_range = true
	
	print("🚪 Jugador entró al área de la puerta")
	print("   - door_id: ", door_id)
	print("   - is_locked: ", is_locked)
	
	# Si ya está desbloqueada, transicionar inmediatamente
	if not is_locked:
		print("   ✓ Puerta desbloqueada, transicionando...")
		play_open_sound()
		RoomManager.call_deferred("load_room", next_room_path, spawn_name)
		return
	
	# Si está bloqueada, mostrar mensaje de interacción
	print("   🔒 Puerta bloqueada, mostrando mensaje de interacción")
	show_interaction_message()

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_in_range = false
	hide_interaction_message()
	print("🚪 Jugador salió del área de la puerta")

# Detectar cuando el jugador presiona E para abrir el teclado
func _input(event: InputEvent) -> void:
	if not player_in_range or not is_locked:
		return
	
	if event.is_action_pressed("interact"):
		print("⌨️ Tecla E presionada, abriendo teclado")
		show_keypad()
		get_viewport().set_input_as_handled()

# ==================== SISTEMA DE MENSAJES ====================

func show_interaction_message() -> void:
	if not show_notification:
		return
	
	var message = "E para interactuar"
	
	# Buscar el InteractingComponent del jugador y mostrar el mensaje
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var interact_comp = player.get_node_or_null("InteractingComponent")
		if interact_comp and interact_comp.has_method("show_door_message"):
			interact_comp.show_door_message(message)
			print("   ✓ Mensaje mostrado: ", message)
		else:
			print("   ⚠️ InteractingComponent no encontrado")
	
	print("💬 ", message)

func hide_interaction_message() -> void:
	# Ocultar el mensaje cuando el jugador se aleja
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var interact_comp = player.get_node_or_null("InteractingComponent")
		if interact_comp and interact_comp.has_method("hide_door_message"):
			interact_comp.hide_door_message()

# ==================== SISTEMA DE TECLADO ====================

func show_keypad() -> void:
	if keypad_ui_scene == null:
		push_error("❌ No se configuró keypad_ui_scene para ", name)
		return
	
	# Ocultar mensaje de interacción mientras el teclado está abierto
	hide_interaction_message()
	
	# Instanciar el teclado si no existe
	if keypad_instance == null:
		keypad_instance = keypad_ui_scene.instantiate()
		get_tree().root.add_child(keypad_instance)
		
		# Conectar señales
		if keypad_instance.has_signal("code_correct"):
			keypad_instance.connect("code_correct", Callable(self, "_on_code_correct"))
		if keypad_instance.has_signal("code_incorrect"):
			keypad_instance.connect("code_incorrect", Callable(self, "_on_code_incorrect"))
		
		print("   ✓ Teclado instanciado y señales conectadas")
	
	# Mostrar el teclado con el código correcto
	if keypad_instance.has_method("show_keypad"):
		keypad_instance.show_keypad(correct_code)
		code_was_entered = false
		print("   ✓ Teclado mostrado con código: ", correct_code)
	
	print("🔢 Mostrando teclado para puerta: ", door_id)

func _on_code_correct() -> void:
	if code_was_entered:
		return
	
	code_was_entered = true
	print("✅ Código correcto para puerta: ", door_id)
	
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
	print("💡 Ahora funciona como puerta normal (paso automático)")

# ==================== VISUAL ====================

func update_visual() -> void:
	# Cambiar color del área para debug (verde = desbloqueado, rojo = bloqueado)
	modulate = Color.GREEN if not is_locked else Color.RED
	
	# Si tienes un sprite de candado, ocultarlo cuando está desbloqueado
	if locked_sprite:
		locked_sprite.visible = is_locked

# ==================== SONIDOS ====================


func play_open_sound() -> void:
	if open_sound:
		AudioManager.play_global_sound(open_sound, -5.0)

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
