# victory_exit.gd
# Puerta especial que muestra pantalla de victoria cuando el jugador tiene la llave correcta
extends Area2D

# ==================== CONFIGURACIÓN ====================
@export_group("Sistema de Bloqueo")
@export var required_item: String = "llave_director"  # Item necesario para ganar

# ==================== SONIDOS ====================
@export_group("Sonidos")
@export var locked_sound: AudioStream = null   # Cuando intenta sin la llave
@export var victory_sound: AudioStream = null  # Cuando gana (opcional, además de la música)

# ==================== MENSAJES ====================
@export_group("Mensajes")
@export var locked_message: String = "Está cerrado con llave"
@export var show_notification: bool = true

# ==================== REFERENCIAS ====================
var victory_menu: CanvasLayer = null
var player_in_range: bool = false
var is_locked: bool = true

# ==================== VISUAL FEEDBACK ====================
@onready var locked_sprite: Sprite2D = $LockedSprite if has_node("LockedSprite") else null

func _ready() -> void:
	# Verificar si el jugador tiene la llave
	update_lock_state()
	
	# Conectar señales
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Buscar el menú de victoria en la escena
	find_victory_menu()
	
	# Actualizar visual
	update_visual()
	
	print("🏆 VictoryExit inicializado")

func _process(_delta: float) -> void:
	# Verificar constantemente si consiguió la llave
	if is_locked:
		var old_locked = is_locked
		update_lock_state()
		
		# Si se desbloqueó mientras el jugador está cerca, actualizar UI
		if old_locked and not is_locked and player_in_range:
			hide_door_notification()

func update_lock_state() -> void:
	# Verificar si tiene el item requerido
	is_locked = not GameState.has_item(required_item)

func find_victory_menu() -> void:
	# Buscar el menú de victoria en el árbol de escenas
	var main = get_tree().root.get_node_or_null("main")
	if main:
		victory_menu = main.get_node_or_null("VictoryMenu")
	
	if victory_menu:
		print("✅ VictoryMenu encontrado")
	else:
		push_warning("⚠️ VictoryMenu no encontrado en main")

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_in_range = true
	
	print("🚪 Jugador entró a la puerta de victoria")
	print("   - is_locked: ", is_locked)
	print("   - tiene llave: ", GameState.has_item(required_item))
	
	# Si está desbloqueada (tiene la llave), ¡VICTORIA!
	if not is_locked:
		print("   🏆 ¡VICTORIA!")
		trigger_victory()
		return
	
	# Si está bloqueada, mostrar mensaje
	print("   🔒 Puerta bloqueada, necesita llave")
	show_door_notification()
	play_locked_sound()

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_in_range = false
	hide_door_notification()
	print("🚪 Jugador salió de la puerta de victoria")

# ==================== VICTORIA ====================

func trigger_victory() -> void:
	# Reproducir sonido de victoria (opcional)
	if victory_sound:
		AudioManager.play_sound(victory_sound, global_position, 0.0)
	
	# Mostrar el menú de victoria
	if victory_menu:
		# Pausar el juego
		get_tree().paused = true
		
		# Mostrar cursor
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		# Mostrar menú
		victory_menu.show()
		
		# Reproducir música del menú de victoria
		var audio_player = victory_menu.get_node_or_null("AudioStreamPlayer")
		if audio_player and audio_player.stream:
			audio_player.play()
		
		print("🎉 Pantalla de victoria mostrada")
	else:
		push_error("❌ VictoryMenu no está disponible")

# ==================== NOTIFICACIONES UI ====================

func show_door_notification() -> void:
	if not show_notification:
		return
	
	var message = locked_message
	
	# Buscar el InteractingComponent del jugador y mostrar el mensaje
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var interact_comp = player.get_node_or_null("InteractingComponent")
		if interact_comp and interact_comp.has_method("show_door_message"):
			interact_comp.show_door_message(message)
			print("   ✓ Mensaje mostrado: ", message)
	
	print("🔒 ", message)

func hide_door_notification() -> void:
	# Ocultar el mensaje cuando el jugador se aleja
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var interact_comp = player.get_node_or_null("InteractingComponent")
		if interact_comp and interact_comp.has_method("hide_door_message"):
			interact_comp.hide_door_message()

# ==================== SONIDOS ====================

func play_locked_sound() -> void:
	if locked_sound:
		AudioManager.play_sound(locked_sound, global_position, -5.0)
		print("🔊 Reproduciendo sonido de puerta bloqueada")

# ==================== VISUAL ====================

func update_visual() -> void:
	# Cambiar color del área para debug (verde = desbloqueado, rojo = bloqueado)
	modulate = Color.GREEN if not is_locked else Color.RED
	
	# Si tienes un sprite de candado, ocultarlo cuando está desbloqueado
	if locked_sprite:
		locked_sprite.visible = is_locked

# ==================== DEBUG ====================

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if required_item.is_empty():
		warnings.append("Configura 'required_item' con el nombre de la llave necesaria")
	
	return warnings
