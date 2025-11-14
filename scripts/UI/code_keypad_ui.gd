# code_keypad_ui.gd
# UI de teclado numérico para ingresar códigos de acceso
extends CanvasLayer

# Señales
signal code_correct()
signal code_incorrect()

# Referencias a nodos
@onready var background: ColorRect = $Background
@onready var panel: Panel = $Panel
@onready var display: Label = $Panel/Display
@onready var button_container: GridContainer = $Panel/ButtonContainer
@onready var close_button: Button = $Panel/CloseButton

# Sonidos
@onready var button_sound: AudioStreamPlayer = $ButtonSound if has_node("ButtonSound") else null
@onready var success_sound: AudioStreamPlayer = $SuccessSound if has_node("SuccessSound") else null
@onready var error_sound: AudioStreamPlayer = $ErrorSound if has_node("ErrorSound") else null

# Configuración
@export var correct_code: String = "1234"
@export var max_digits: int = 4

# Colores de la PANTALLA (Display) - Fondo y Borde
const DISPLAY_COLOR_NORMAL = Color(0.12, 0.24, 0.47, 1.0)        # Azul oscuro #1E3C78
const DISPLAY_BORDER_NORMAL = Color(0.2, 0.35, 0.59, 1.0)        # Azul más claro #325A96

const DISPLAY_COLOR_SUCCESS = Color(0.1, 0.5, 0.1, 1.0)          # Verde oscuro #19801A
const DISPLAY_BORDER_SUCCESS = Color(0.2, 0.7, 0.2, 1.0)         # Verde más claro #33B333

const DISPLAY_COLOR_ERROR = Color(0.5, 0.1, 0.1, 1.0)            # Rojo oscuro #801A1A
const DISPLAY_BORDER_ERROR = Color(0.7, 0.2, 0.2, 1.0)           # Rojo más claro #B33333

# Variables internas
var current_input: String = ""
var is_locked: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	# Configurar fondo oscuro transparente
	if background:
		background.color = Color(0, 0, 0, 0.8)
	
	# Configurar panel (cuerpo del teclado)
	configure_panel()
	
	# Configurar display (pantalla)
	configure_display()
	
	# Crear botones numéricos
	create_number_buttons()
	
	# Conectar botón de cerrar
	if close_button:
		configure_close_button()
		close_button.pressed.connect(_on_close_pressed)
	
	print("✅ CodeKeypadUI inicializado con estilos")

func configure_panel() -> void:
	if not panel:
		return
	
	# Panel gris oscuro casi negro
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.14, 1.0)  # #1E1E23
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.2, 0.2, 0.22, 1.0)  # #323237
	panel.add_theme_stylebox_override("panel", style)

func configure_display() -> void:
	if not display:
		return
	
	# Pantalla azul inicial con borde
	var style = StyleBoxFlat.new()
	style.bg_color = DISPLAY_COLOR_NORMAL
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = DISPLAY_BORDER_NORMAL
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	display.add_theme_stylebox_override("normal", style)
	
	# Texto blanco centrado
	display.add_theme_color_override("font_color", Color.WHITE)
	display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func configure_close_button() -> void:
	if not close_button:
		return
	
	# Solo configurar focus_mode, el resto se maneja desde el Inspector
	close_button.focus_mode = Control.FOCUS_NONE

func create_number_buttons() -> void:
	if not button_container:
		return
	
	button_container.columns = 3
	var button_size = Vector2(28, 14)
	
	# Crear botones del 1 al 9
	for i in range(1, 10):
		var button = create_styled_button(str(i), button_size)
		button.pressed.connect(_on_number_pressed.bind(str(i)))
		button_container.add_child(button)
	
	# Botón 0 centrado en la última fila
	var spacer_left = Control.new()
	spacer_left.custom_minimum_size = button_size
	button_container.add_child(spacer_left)
	
	var button_0 = create_styled_button("0", button_size)
	button_0.pressed.connect(_on_number_pressed.bind("0"))
	button_container.add_child(button_0)
	
	var spacer_right = Control.new()
	spacer_right.custom_minimum_size = button_size
	button_container.add_child(spacer_right)
	
	print("✅ Botones numéricos creados con estilos")

func create_styled_button(text: String, size: Vector2) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = size
	button.focus_mode = Control.FOCUS_NONE  # Sin focus
	
	# Estilo normal (gris claro)
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.35, 0.35, 0.38, 1.0)  # Gris claro #595960
	style_normal.border_width_left = 1
	style_normal.border_width_top = 1
	style_normal.border_width_right = 1
	style_normal.border_width_bottom = 1
	style_normal.border_color = Color(0.25, 0.25, 0.28, 1.0)  # Gris más oscuro
	style_normal.corner_radius_top_left = 3
	style_normal.corner_radius_top_right = 3
	style_normal.corner_radius_bottom_left = 3
	style_normal.corner_radius_bottom_right = 3
	
	# Estilo hover (más claro)
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.45, 0.45, 0.48, 1.0)  # Gris más claro
	style_hover.border_width_left = 1
	style_hover.border_width_top = 1
	style_hover.border_width_right = 1
	style_hover.border_width_bottom = 1
	style_hover.border_color = Color(0.55, 0.55, 0.58, 1.0)
	style_hover.corner_radius_top_left = 3
	style_hover.corner_radius_top_right = 3
	style_hover.corner_radius_bottom_left = 3
	style_hover.corner_radius_bottom_right = 3
	
	# Estilo pressed (más oscuro)
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.25, 0.25, 0.28, 1.0)
	style_pressed.border_width_left = 1
	style_pressed.border_width_top = 1
	style_pressed.border_width_right = 1
	style_pressed.border_width_bottom = 1
	style_pressed.border_color = Color(0.15, 0.15, 0.18, 1.0)
	style_pressed.corner_radius_top_left = 3
	style_pressed.corner_radius_top_right = 3
	style_pressed.corner_radius_bottom_left = 3
	style_pressed.corner_radius_bottom_right = 3
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	# Texto blanco
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 12)
	
	return button

func show_keypad(code: String = "") -> void:
	if not code.is_empty():
		correct_code = code
	
	current_input = ""
	_update_display()
	
	# Restaurar color azul del display (fondo y borde)
	_set_display_color(DISPLAY_COLOR_NORMAL, DISPLAY_BORDER_NORMAL)
	
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	show()
	print("🔢 Teclado numérico mostrado | Código correcto: ", correct_code)

func _on_number_pressed(number: String) -> void:
	if is_locked:
		return
	
	if current_input.length() >= max_digits:
		return
	
	current_input += number
	_update_display()
	
	if button_sound and button_sound.stream:
		button_sound.play()
	
	print("🔢 Dígito ingresado: ", number, " | Input actual: ", current_input)
	
	if current_input.length() == max_digits:
		await get_tree().create_timer(0.3).timeout
		_check_code()

func _check_code() -> void:
	if is_locked:
		return
	
	is_locked = true
	
	if current_input == correct_code:
		_on_code_success()
	else:
		_on_code_failure()
	
	await get_tree().create_timer(1.5).timeout
	is_locked = false

func _on_code_success() -> void:
	print("✅ Código correcto!")
	
	# Cambiar display a verde (fondo y borde)
	_set_display_color(DISPLAY_COLOR_SUCCESS, DISPLAY_BORDER_SUCCESS)
	
	if display:
		display.text = "ABIERTO"
	
	if success_sound and success_sound.stream:
		success_sound.play()
	
	code_correct.emit()
	
	await get_tree().create_timer(2.0).timeout
	_close_keypad()

func _on_code_failure() -> void:
	print("❌ Código incorrecto!")
	
	# Cambiar display a rojo (fondo y borde)
	_set_display_color(DISPLAY_COLOR_ERROR, DISPLAY_BORDER_ERROR)
	
	if display:
		display.text = "ERROR"
	
	if error_sound and error_sound.stream:
		error_sound.play()
	
	code_incorrect.emit()
	
	await get_tree().create_timer(1.0).timeout
	
	# Restaurar color azul y limpiar input
	_set_display_color(DISPLAY_COLOR_NORMAL, DISPLAY_BORDER_NORMAL)
	current_input = ""
	_update_display()

func _on_close_pressed() -> void:
	_close_keypad()

func _close_keypad() -> void:
	hide()
	get_tree().paused = false
	
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	print("❌ Teclado numérico cerrado")

func _update_display() -> void:
	if not display:
		return
	
	# Mostrar asteriscos
	display.text = "*".repeat(current_input.length())

func _set_display_color(bg_color: Color, border_color: Color) -> void:
	if not display:
		return
	
	var style = display.get_theme_stylebox("normal")
	if style and style is StyleBoxFlat:
		style.bg_color = bg_color
		style.border_color = border_color

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_close_keypad()
		get_viewport().set_input_as_handled()

func set_correct_code(new_code: String) -> void:
	correct_code = new_code
	print("🔑 Código actualizado: ", correct_code)
