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

# Sonidos (opcionales)
@onready var button_sound: AudioStreamPlayer = $ButtonSound if has_node("ButtonSound") else null
@onready var success_sound: AudioStreamPlayer = $SuccessSound if has_node("SuccessSound") else null
@onready var error_sound: AudioStreamPlayer = $ErrorSound if has_node("ErrorSound") else null

# Configuración
@export var correct_code: String = "1234"  # Código correcto (configurable)
@export var max_digits: int = 4  # Máximo de dígitos

# Colores del panel
const COLOR_NORMAL = Color(0.2, 0.3, 0.8, 1.0)  # Azul
const COLOR_SUCCESS = Color(0.2, 0.8, 0.2, 1.0)  # Verde
const COLOR_ERROR = Color(0.8, 0.2, 0.2, 1.0)    # Rojo

# Variables internas
var current_input: String = ""
var is_locked: bool = false
var original_panel_color: Color = COLOR_NORMAL

func _ready() -> void:
	# Configurar process_mode para funcionar durante la pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Ocultar inicialmente
	hide()
	
	# Configurar fondo oscuro
	if background:
		background.color = Color(0, 0, 0, 0.8)  # Negro con 80% opacidad
	
	# Configurar panel sólido azul
	if panel:
		var style = StyleBoxFlat.new()
		style.bg_color = COLOR_NORMAL
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color.WHITE
		panel.add_theme_stylebox_override("panel", style)
	
	# Configurar display centrado
	if display:
		display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Crear botones numéricos (0-9)
	create_number_buttons()
	
	# Conectar botón de cerrar
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	print("✅ CodeKeypadUI inicializado")

func create_number_buttons() -> void:
	if not button_container:
		return
	
	# Configurar el GridContainer
	button_container.columns = 3
	
	# Calcular tamaño de botones proporcional al panel
	# Panel: 140x140, Display: ~25px, espacio para botones: ~100px
	# 4 filas + separaciones, 3 columnas + separaciones
	var button_size = Vector2(35, 18)
	
	# Crear botones del 1 al 9
	for i in range(1, 10):
		var button = Button.new()
		button.text = str(i)
		button.custom_minimum_size = button_size
		
		# Estilo del botón (fondo transparente con borde blanco)
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color(1, 1, 1, 0)  # Transparente
		style_normal.border_width_left = 1
		style_normal.border_width_top = 1
		style_normal.border_width_right = 1
		style_normal.border_width_bottom = 1
		style_normal.border_color = Color.WHITE
		
		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = Color(1, 1, 1, 0.2)  # Semi-transparente al hover
		style_hover.border_width_left = 1
		style_hover.border_width_top = 1
		style_hover.border_width_right = 1
		style_hover.border_width_bottom = 1
		style_hover.border_color = Color.WHITE
		
		var style_pressed = StyleBoxFlat.new()
		style_pressed.bg_color = Color(1, 1, 1, 0.3)  # Más visible al presionar
		style_pressed.border_width_left = 1
		style_pressed.border_width_top = 1
		style_pressed.border_width_right = 1
		style_pressed.border_width_bottom = 1
		style_pressed.border_color = Color.WHITE
		
		button.add_theme_stylebox_override("normal", style_normal)
		button.add_theme_stylebox_override("hover", style_hover)
		button.add_theme_stylebox_override("pressed", style_pressed)
		
		# Color del texto
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_font_size_override("font_size", 12)
		
		button.pressed.connect(_on_number_pressed.bind(str(i)))
		button_container.add_child(button)
	
	# Agregar botón 0 al final (centrado en la última fila)
	var spacer_left = Control.new()
	spacer_left.custom_minimum_size = button_size
	button_container.add_child(spacer_left)
	
	var button_0 = Button.new()
	button_0.text = "0"
	button_0.custom_minimum_size = button_size
	
	# Mismo estilo que los otros botones (fondo transparente)
	var style_normal_0 = StyleBoxFlat.new()
	style_normal_0.bg_color = Color(1, 1, 1, 0)
	style_normal_0.border_width_left = 1
	style_normal_0.border_width_top = 1
	style_normal_0.border_width_right = 1
	style_normal_0.border_width_bottom = 1
	style_normal_0.border_color = Color.WHITE
	
	var style_hover_0 = StyleBoxFlat.new()
	style_hover_0.bg_color = Color(1, 1, 1, 0.2)
	style_hover_0.border_width_left = 1
	style_hover_0.border_width_top = 1
	style_hover_0.border_width_right = 1
	style_hover_0.border_width_bottom = 1
	style_hover_0.border_color = Color.WHITE
	
	var style_pressed_0 = StyleBoxFlat.new()
	style_pressed_0.bg_color = Color(1, 1, 1, 0.3)
	style_pressed_0.border_width_left = 1
	style_pressed_0.border_width_top = 1
	style_pressed_0.border_width_right = 1
	style_pressed_0.border_width_bottom = 1
	style_pressed_0.border_color = Color.WHITE
	
	button_0.add_theme_stylebox_override("normal", style_normal_0)
	button_0.add_theme_stylebox_override("hover", style_hover_0)
	button_0.add_theme_stylebox_override("pressed", style_pressed_0)
	button_0.add_theme_color_override("font_color", Color.WHITE)
	button_0.add_theme_font_size_override("font_size", 12)
	
	button_0.pressed.connect(_on_number_pressed.bind("0"))
	button_container.add_child(button_0)
	
	var spacer_right = Control.new()
	spacer_right.custom_minimum_size = button_size
	button_container.add_child(spacer_right)
	
	print("✅ Botones numéricos creados")

func show_keypad(code: String = "") -> void:
	if not code.is_empty():
		correct_code = code
	
	current_input = ""
	_update_display()
	
	# Restaurar color azul del panel
	_set_panel_color(COLOR_NORMAL)
	
	# Pausar el juego y mostrar cursor
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	show()
	print("🔢 Teclado numérico mostrado | Código correcto: ", correct_code)

func _on_number_pressed(number: String) -> void:
	if is_locked:
		return
	
	# Limitar la cantidad de dígitos
	if current_input.length() >= max_digits:
		return
	
	current_input += number
	_update_display()
	
	# Reproducir sonido
	if button_sound and button_sound.stream:
		button_sound.play()
	
	print("🔢 Dígito ingresado: ", number, " | Input actual: ", current_input)
	
	# Si ya ingresó 4 dígitos, verificar automáticamente
	if current_input.length() == max_digits:
		await get_tree().create_timer(0.3).timeout  # Pequeña pausa para que vea el último número
		_check_code()

func _check_code() -> void:
	if is_locked:
		return
	
	# Bloquear temporalmente para evitar múltiples verificaciones
	is_locked = true
	
	# Verificar si el código es correcto
	if current_input == correct_code:
		_on_code_success()
	else:
		_on_code_failure()
	
	# Desbloquear después de un momento
	await get_tree().create_timer(1.5).timeout
	is_locked = false

func _on_code_success() -> void:
	print("✅ Código correcto!")
	
	# Cambiar todo el panel a verde
	_set_panel_color(COLOR_SUCCESS)
	
	# Mostrar mensaje de éxito en el display
	if display:
		display.text = "ABIERTO"
	
	# Reproducir sonido de éxito
	if success_sound and success_sound.stream:
		success_sound.play()
	
	# Emitir señal PRIMERO (para que la puerta se desbloquee)
	code_correct.emit()
	
	# Esperar 2 segundos y luego cerrar
	await get_tree().create_timer(2.0).timeout
	_close_keypad()

func _on_code_failure() -> void:
	print("❌ Código incorrecto!")
	
	# Cambiar todo el panel a rojo
	_set_panel_color(COLOR_ERROR)
	
	# Mostrar mensaje de error en el display
	if display:
		display.text = "ERROR"
	
	# Reproducir sonido de error
	if error_sound and error_sound.stream:
		error_sound.play()
	
	# Emitir señal
	code_incorrect.emit()
	
	# Esperar un momento antes de limpiar
	await get_tree().create_timer(1.0).timeout
	
	# Restaurar color azul y limpiar input
	_set_panel_color(COLOR_NORMAL)
	current_input = ""
	_update_display()

func _on_close_pressed() -> void:
	_close_keypad()

func _close_keypad() -> void:
	hide()
	get_tree().paused = false
	
	# Ocultar cursor
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	print("❌ Teclado numérico cerrado")

func _update_display() -> void:
	if not display:
		return
	
	# Mostrar asteriscos en lugar de los números reales
	display.text = "*".repeat(current_input.length())

func _set_panel_color(color: Color) -> void:
	if not panel:
		return
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE
	panel.add_theme_stylebox_override("panel", style)

# Permitir cerrar con ESC
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_close_keypad()
		get_viewport().set_input_as_handled()

# Método para cambiar el código correcto dinámicamente
func set_correct_code(new_code: String) -> void:
	correct_code = new_code
	print("🔑 Código actualizado: ", correct_code)
