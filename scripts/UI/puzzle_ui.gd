# puzzle_ui.gd
# Sistema híbrido: imágenes para preguntas/feedback + botones Godot para opciones
extends CanvasLayer

# ==================== SEÑALES ====================
signal puzzle_solved()
signal puzzle_closed()

# ==================== REFERENCIAS A NODOS ====================
@onready var background: ColorRect = $Background
@onready var panel: Panel = $Panel
@onready var background_image: TextureRect = $Panel/BackgroundImage
@onready var button_a: Button = $Panel/ButtonA
@onready var button_b: Button = $Panel/ButtonB
@onready var button_c: Button = $Panel/ButtonC
@onready var button_d: Button = $Panel/ButtonD
@onready var close_button: Button = $Panel/CloseButton

# ==================== SONIDOS ====================
@onready var correct_sound: AudioStreamPlayer = $CorrectSound if has_node("CorrectSound") else null
@onready var wrong_sound: AudioStreamPlayer = $WrongSound if has_node("WrongSound") else null

# ==================== CONFIGURACIÓN DEL PUZZLE ====================
var puzzle_data: Dictionary = {}
var current_stage: int = 0
var is_locked: bool = false
var completed_texture: Texture2D = null

# ==================== ESTILOS ====================
const PANEL_SIZE = Vector2(210, 145)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	# Configurar fondo oscuro
	if background:
		background.color = Color(0, 0, 0, 0.8)
	
	# Configurar panel
	configure_panel()
	
	# Conectar señales de botones
	if button_a and not button_a.is_connected("pressed", Callable(self, "_on_button_pressed")):
		button_a.pressed.connect(_on_button_pressed.bind(0))
	if button_b and not button_b.is_connected("pressed", Callable(self, "_on_button_pressed")):
		button_b.pressed.connect(_on_button_pressed.bind(1))
	if button_c and not button_c.is_connected("pressed", Callable(self, "_on_button_pressed")):
		button_c.pressed.connect(_on_button_pressed.bind(2))
	if button_d and not button_d.is_connected("pressed", Callable(self, "_on_button_pressed")):
		button_d.pressed.connect(_on_button_pressed.bind(3))
	if close_button and not close_button.is_connected("pressed", Callable(self, "_on_close_pressed")):
		close_button.pressed.connect(_on_close_pressed)
	
	print("✅ PuzzleUI (Híbrido) inicializado")

func configure_panel() -> void:
	if not panel:
		return
	
	# Panel con fondo transparente
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	panel.add_theme_stylebox_override("panel", style)
	
	# Resetear anchors
	panel.anchor_left = 0
	panel.anchor_top = 0
	panel.anchor_right = 0
	panel.anchor_bottom = 0
	
	# Establecer tamaño exacto
	panel.custom_minimum_size = PANEL_SIZE
	panel.size = PANEL_SIZE
	
	# Centrar panel
	var viewport_size = get_viewport().get_visible_rect().size
	panel.position = (viewport_size - PANEL_SIZE) / 2

# ==================== MOSTRAR PUZZLE ====================
func show_puzzle(data: Dictionary) -> void:
	puzzle_data = data
	current_stage = 0
	is_locked = false
	
	# Cargar imagen de completado
	completed_texture = data.get("completed_texture", null)
	
	# Mostrar primera etapa
	display_stage(current_stage)
	
	# Pausar juego y mostrar cursor
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	show()
	print("🧩 Puzzle mostrado: ", puzzle_data.get("puzzle_id", "unknown"))

# ==================== MOSTRAR ETAPA ====================
func display_stage(stage_index: int) -> void:
	if stage_index >= puzzle_data["stages"].size():
		_on_puzzle_completed()
		return
	
	var stage_data = puzzle_data["stages"][stage_index]
	
	# Cambiar imagen de fondo (pregunta)
	if background_image and stage_data.has("question_texture"):
		background_image.texture = stage_data["question_texture"]
	
	# Configurar botones con los textos y tamaños de fuente
	configure_button_texts(stage_data)
	
	# Habilitar botones
	enable_buttons(true)
	show_buttons(true)
	
	print("📄 Etapa %d/%d" % [stage_index + 1, puzzle_data["stages"].size()])

# ==================== CONFIGURAR TEXTOS DE BOTONES ====================
func configure_button_texts(stage_data: Dictionary) -> void:
	var options = stage_data.get("options", [])
	var buttons = [button_a, button_b, button_c, button_d]
	
	for i in range(min(buttons.size(), options.size())):
		if buttons[i] == null:
			continue
		
		var option = options[i]
		var button = buttons[i]
		
		# Configurar texto
		var text = option.get("button_text", "")
		button.text = text
		
		# Configurar tamaño de fuente
		var font_size = option.get("font_size", 9)
		button.add_theme_font_size_override("font_size", font_size)
		
		print("  Botón %d: texto='%s' font_size=%d" % [i, text, font_size])

# ==================== BOTÓN PRESIONADO ====================
func _on_button_pressed(button_index: int) -> void:
	if is_locked:
		return
	
	is_locked = true
	print("🔘 Botón %d presionado" % button_index)
	
	var stage_data = puzzle_data["stages"][current_stage]
	var options = stage_data.get("options", [])
	
	if button_index >= options.size():
		print("❌ Botón fuera de rango")
		is_locked = false
		return
	
	var option = options[button_index]
	var is_correct = option.get("is_correct", false)
	var feedback_texture = option.get("feedback_texture", null)
	
	# Deshabilitar y ocultar botones mientras se muestra feedback
	enable_buttons(false)
	show_buttons(false)
	
	# Mostrar imagen de feedback
	if feedback_texture and background_image:
		background_image.texture = feedback_texture
	
	# Reproducir sonido
	if is_correct:
		if correct_sound and correct_sound.stream:
			correct_sound.play()
	else:
		if wrong_sound and wrong_sound.stream:
			wrong_sound.play()
	
	# Esperar 2.5 segundos
	await get_tree().create_timer(2.5).timeout
	
	if is_correct:
		# Avanzar a siguiente etapa
		current_stage += 1
		is_locked = false
		display_stage(current_stage)
	else:
		# Volver a mostrar la pregunta
		is_locked = false
		display_stage(current_stage)

# ==================== CONTROL DE BOTONES ====================
func enable_buttons(enabled: bool) -> void:
	if button_a:
		button_a.disabled = not enabled
	if button_b:
		button_b.disabled = not enabled
	if button_c:
		button_c.disabled = not enabled
	if button_d:
		button_d.disabled = not enabled

func show_buttons(visible_state: bool) -> void:
	if button_a:
		button_a.visible = visible_state
	if button_b:
		button_b.visible = visible_state
	if button_c:
		button_c.visible = visible_state
	if button_d:
		button_d.visible = visible_state

# ==================== PUZZLE COMPLETADO ====================
func _on_puzzle_completed() -> void:
	print("✅ Puzzle completado!")
	
	puzzle_solved.emit()
	
	# Mostrar pantalla de completado
	if completed_texture and background_image:
		background_image.texture = completed_texture
		show_buttons(false)
		
		await get_tree().create_timer(3.0).timeout
	else:
		await get_tree().create_timer(1.0).timeout
	
	_close_puzzle()

# ==================== CERRAR PUZZLE ====================
func _on_close_pressed() -> void:
	_close_puzzle()

func _close_puzzle() -> void:
	hide()
	get_tree().paused = false
	
	# Restaurar visibilidad de botones
	show_buttons(true)
	
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	puzzle_closed.emit()
	print("❌ Puzzle cerrado")

# ==================== INPUT ====================
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_close_puzzle()
		get_viewport().set_input_as_handled()
