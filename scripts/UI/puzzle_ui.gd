# puzzle_ui.gd
# Sistema genérico y reutilizable para puzzles con múltiples pantallas
extends CanvasLayer

# ==================== SEÑALES ====================
signal puzzle_solved()
signal puzzle_closed()

# ==================== REFERENCIAS A NODOS ====================
@onready var background: ColorRect = $Background
@onready var panel: Panel = $Panel
@onready var background_image: TextureRect = $Panel/BackgroundImage
@onready var question_label: Label = $Panel/QuestionLabel
@onready var options_container: VBoxContainer = $Panel/OptionsContainer
@onready var close_button: Button = $Panel/CloseButton
@onready var feedback_label: Label = $Panel/FeedbackLabel

# ==================== SONIDOS ====================
@onready var correct_sound: AudioStreamPlayer = $CorrectSound if has_node("CorrectSound") else null
@onready var wrong_sound: AudioStreamPlayer = $WrongSound if has_node("WrongSound") else null
@onready var button_sound: AudioStreamPlayer = $ButtonSound if has_node("ButtonSound") else null

# ==================== CONFIGURACIÓN DEL PUZZLE ====================
var puzzle_data: Dictionary = {}
var current_stage: int = 0
var is_locked: bool = false

# ==================== ESTILOS ====================
const PANEL_SIZE = Vector2(280, 180)
const OPTION_BUTTON_SIZE = Vector2(260, 20)

# Colores
const FEEDBACK_COLOR_CORRECT = Color(0.2, 0.8, 0.2, 1.0)
const FEEDBACK_COLOR_WRONG = Color(0.8, 0.2, 0.2, 1.0)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	# Configurar fondo oscuro transparente
	if background:
		background.color = Color(0, 0, 0, 0.8)
	
	# Configurar panel
	configure_panel()
	
	# Configurar botón de cerrar
	if close_button:
		close_button.focus_mode = Control.FOCUS_NONE
		close_button.pressed.connect(_on_close_pressed)
	
	# Ocultar feedback inicialmente
	if feedback_label:
		feedback_label.visible = false
	
	print("✅ PuzzleUI inicializado")

func configure_panel() -> void:
	if not panel:
		return
	
	# Panel gris oscuro
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.14, 1.0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.2, 0.2, 0.22, 1.0)
	panel.add_theme_stylebox_override("panel", style)
	
	# Centrar panel
	panel.custom_minimum_size = PANEL_SIZE
	panel.size = PANEL_SIZE
	var viewport_size = get_viewport().get_visible_rect().size
	panel.position = (viewport_size - PANEL_SIZE) / 2

# ==================== MOSTRAR PUZZLE ====================
func show_puzzle(data: Dictionary) -> void:
	puzzle_data = data
	current_stage = 0
	is_locked = false
	
	# Configurar imagen de fondo si existe
	if puzzle_data.has("background_texture") and puzzle_data["background_texture"] != null:
		background_image.texture = puzzle_data["background_texture"]
		background_image.visible = true
	else:
		background_image.visible = false
	
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
		# Puzzle completado
		_on_puzzle_completed()
		return
	
	var stage_data = puzzle_data["stages"][stage_index]
	
	# Ocultar feedback anterior
	if feedback_label:
		feedback_label.visible = false
	
	# Actualizar pregunta
	if question_label:
		question_label.text = stage_data.get("question", "")
	
	# Limpiar opciones anteriores
	for child in options_container.get_children():
		child.queue_free()
	
	# Crear botones de opciones
	var options = stage_data.get("options", [])
	for i in range(options.size()):
		var option = options[i]
		var button = create_option_button(option["text"], i, option["is_correct"], option["feedback"])
		options_container.add_child(button)
	
	print("📄 Mostrando etapa %d/%d" % [stage_index + 1, puzzle_data["stages"].size()])

# ==================== CREAR BOTÓN DE OPCIÓN ====================
func create_option_button(text: String, index: int, is_correct: bool, feedback_text: String) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = OPTION_BUTTON_SIZE
	button.focus_mode = Control.FOCUS_NONE
	
	# Estilo normal
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.25, 0.25, 0.28, 1.0)
	style_normal.border_width_left = 2
	style_normal.border_width_top = 2
	style_normal.border_width_right = 2
	style_normal.border_width_bottom = 2
	style_normal.border_color = Color(0.35, 0.35, 0.38, 1.0)
	style_normal.corner_radius_top_left = 3
	style_normal.corner_radius_top_right = 3
	style_normal.corner_radius_bottom_left = 3
	style_normal.corner_radius_bottom_right = 3
	
	# Estilo hover
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.35, 0.35, 0.38, 1.0)
	style_hover.border_width_left = 2
	style_hover.border_width_top = 2
	style_hover.border_width_right = 2
	style_hover.border_width_bottom = 2
	style_hover.border_color = Color(0.45, 0.45, 0.48, 1.0)
	style_hover.corner_radius_top_left = 3
	style_hover.corner_radius_top_right = 3
	style_hover.corner_radius_bottom_left = 3
	style_hover.corner_radius_bottom_right = 3
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_hover)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 11)
	
	# Conectar señal
	button.pressed.connect(_on_option_selected.bind(is_correct, feedback_text))
	
	return button

# ==================== RESPUESTA SELECCIONADA ====================
func _on_option_selected(is_correct: bool, feedback_text: String) -> void:
	if is_locked:
		return
	
	is_locked = true
	
	# Reproducir sonido
	if button_sound and button_sound.stream:
		button_sound.play()
	
	# Mostrar feedback
	show_feedback(feedback_text, is_correct)
	
	# Esperar antes de continuar
	await get_tree().create_timer(2.5).timeout
	
	if is_correct:
		# Avanzar a la siguiente etapa
		current_stage += 1
		is_locked = false
		display_stage(current_stage)
	else:
		# Respuesta incorrecta, permitir volver a intentar
		is_locked = false
		if feedback_label:
			feedback_label.visible = false

# ==================== MOSTRAR FEEDBACK ====================
func show_feedback(text: String, is_correct: bool) -> void:
	if not feedback_label:
		return
	
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", FEEDBACK_COLOR_CORRECT if is_correct else FEEDBACK_COLOR_WRONG)
	feedback_label.visible = true
	
	# Reproducir sonido
	if is_correct and correct_sound and correct_sound.stream:
		correct_sound.play()
	elif not is_correct and wrong_sound and wrong_sound.stream:
		wrong_sound.play()

# ==================== PUZZLE COMPLETADO ====================
func _on_puzzle_completed() -> void:
	print("✅ Puzzle completado!")
	
	# Mostrar mensaje final
	if feedback_label:
		feedback_label.text = "¡Puzzle completado!"
		feedback_label.add_theme_color_override("font_color", FEEDBACK_COLOR_CORRECT)
		feedback_label.visible = true
	
	# Ocultar pregunta y opciones
	if question_label:
		question_label.visible = false
	for child in options_container.get_children():
		child.visible = false
	
	# Emitir señal
	puzzle_solved.emit()
	
	# Cerrar automáticamente después de 2 segundos
	await get_tree().create_timer(2.0).timeout
	_close_puzzle()

# ==================== CERRAR PUZZLE ====================
func _on_close_pressed() -> void:
	_close_puzzle()

func _close_puzzle() -> void:
	hide()
	get_tree().paused = false
	
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	puzzle_closed.emit()
	print("❌ Puzzle cerrado")

# ==================== INPUT ====================
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_close_puzzle()
		get_viewport().set_input_as_handled()
