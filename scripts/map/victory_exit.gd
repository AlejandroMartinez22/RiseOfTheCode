# victory_exit.gd
# Puerta especial que muestra pantalla de victoria cuando el jugador tiene la llave correcta
extends Area2D

# ==================== CONFIGURACIÓN ====================
@export_group("Sistema de Bloqueo")
@export var required_item: String = "llave_director"  # Item necesario para ganar

# ==================== SONIDOS ====================
@export_group("Sonidos")
@export var locked_sound: AudioStream = null   # Cuando intenta sin la llave
@export var open_sound: AudioStream = null     # Sonido de apertura de la puerta (antes de victoria)

# ==================== MENSAJES ====================
@export_group("Mensajes")
@export var locked_message: String = "Está cerrado con llave"
@export var show_notification: bool = true

# ==================== REFERENCIAS ====================
var victory_menu: CanvasLayer = null
var transition: CanvasLayer = null
var player_in_range: bool = false
var is_locked: bool = true
var victory_triggered: bool = false  # Para evitar múltiples activaciones
var door_sound_player: AudioStreamPlayer = null  # Reproductor de sonido de la puerta

# ==================== VISUAL FEEDBACK ====================
@onready var locked_sprite: Sprite2D = $LockedSprite if has_node("LockedSprite") else null

func _ready() -> void:
	# Verificar si el jugador tiene la llave
	update_lock_state()
	
	# Crear un AudioStreamPlayer para el sonido de la puerta
	door_sound_player = AudioStreamPlayer.new()
	door_sound_player.bus = "Master"
	add_child(door_sound_player)
	
	# Conectar señales
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Buscar referencias necesarias
	find_victory_menu()
	find_transition()
	
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

func find_transition() -> void:
	# Buscar el Transition en main
	var main = get_tree().root.get_node_or_null("main")
	if main:
		transition = main.get_node_or_null("Transition")
	
	if transition:
		print("✅ Transition encontrado")
	else:
		push_warning("⚠️ Transition no encontrado en main")

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_in_range = true
	
	print("🚪 Jugador entró a la puerta de victoria")
	print("   - is_locked: ", is_locked)
	print("   - tiene llave: ", GameState.has_item(required_item))
	
	# Si está desbloqueada (tiene la llave), ¡VICTORIA!
	if not is_locked and not victory_triggered:
		print("   🏆 ¡VICTORIA! Iniciando secuencia...")
		victory_triggered = true
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
	print("🎬 Iniciando secuencia de victoria...")
	
	# PASO 0: Pausar el juego INMEDIATAMENTE para que Max no se mueva
	get_tree().paused = true
	print("⏸️ Juego pausado")
	
	# PASO 1: Reproducir sonido de apertura de puerta y esperar a que termine
	if open_sound:
		# Configurar el reproductor
		door_sound_player.stream = open_sound
		door_sound_player.volume_db = 0.0
		
		# El AudioStreamPlayer debe funcionar aunque el juego esté pausado
		door_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
		
		print("🔊 Reproduciendo sonido de apertura...")
		door_sound_player.play()
		
		# Esperar a que termine el sonido usando la señal finished
		await door_sound_player.finished
		print("✅ Sonido de apertura terminado")
	else:
		print("⚠️ No hay open_sound configurado, continuando...")
		await get_tree().create_timer(0.5).timeout
	
	# PASO 2: Activar transición fade a negro
	if transition:
		print("🎬 Iniciando fade a negro...")
		await play_transition_fade_in()
	
	# PASO 3: Mostrar menú de victoria (mientras está negro)
	if victory_menu:
		victory_menu.show()
		
		# Mostrar cursor
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		# Reproducir música del menú de victoria
		var audio_player = victory_menu.get_node_or_null("AudioStreamPlayer")
		if audio_player and audio_player.stream:
			audio_player.play()
		
		print("🎉 Pantalla de victoria mostrada")
	else:
		push_error("❌ VictoryMenu no está disponible")
	
	# PASO 4: Hacer fade desde negro (revelar menú de victoria)
	if transition:
		print("🎬 Iniciando fade desde negro...")
		await play_transition_fade_out()
	
	print("🏆 Secuencia de victoria completada")

func play_transition_fade_in() -> void:
	# Hacer fade a negro (similar a cuando inicia el juego, pero inverso)
	if not transition:
		return
	
	var color_rect = transition.get_node_or_null("ColorRect")
	if not color_rect:
		return
	
	# Asegurar que empieza transparente
	color_rect.modulate = Color(1, 1, 1, 0)
	transition.show()
	
	# Crear tween para fade a negro
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Funciona aunque esté pausado
	tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 1), 1.0)
	
	await tween.finished

func play_transition_fade_out() -> void:
	# Hacer fade desde negro (revelar el menú de victoria)
	if not transition:
		return
	
	var color_rect = transition.get_node_or_null("ColorRect")
	if not color_rect:
		return
	
	# Crear tween para fade desde negro
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 0), 1.0)
	
	await tween.finished
	
	# Ocultar la transición
	transition.hide()

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
	
	if open_sound == null:
		warnings.append("Se recomienda configurar 'open_sound' para mejor experiencia")
	
	return warnings
