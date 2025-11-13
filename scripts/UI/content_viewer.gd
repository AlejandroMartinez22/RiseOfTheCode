# content_viewer.gd
# Visor modular para notas, tableros y computadores
extends CanvasLayer

# Referencias a nodos
@onready var background: ColorRect = $Background
@onready var content_panel: Panel = $ContentPanel
@onready var texture_rect: TextureRect = $ContentPanel/TextureRect
@onready var prev_button: Button = $ContentPanel/PrevButton
@onready var next_button: Button = $ContentPanel/NextButton
@onready var close_button: Button = $ContentPanel/CloseButton

# Configuraciones de tamaño para cada tipo de contenido
const PANEL_CONFIGS = {
	UIManager.ContentType.NOTE: {
		"size": Vector2(160, 140),
		"position_offset": Vector2(0, 0),
		"close_button_offset": Vector2(6, 1),  # Desde esquina superior derecha
		"prev_button_offset": Vector2(3, 17),   # Desde esquina inferior izquierda
		"next_button_offset": Vector2(6, 17)  # Desde esquina inferior derecha
	},
	UIManager.ContentType.BOARD: {
		"size": Vector2(240, 155),
		"position_offset": Vector2(0, 0),
		"close_button_offset": Vector2(3, 4),
		"prev_button_offset": Vector2(8, 13),
		"next_button_offset": Vector2(1, 13)
	},
	UIManager.ContentType.COMPUTER: {
		"size": Vector2(210, 145),
		"position_offset": Vector2(0, 0),
		"close_button_offset": Vector2(4, 3),
		"prev_button_offset": Vector2(6, 3),
		"next_button_offset": Vector2(3, 3)
	}
}

# Estado actual
var current_textures: Array[Texture2D] = []
var current_page: int = 0
var current_type: UIManager.ContentType = UIManager.ContentType.NOTE

func _ready() -> void:
	hide()
	
	# Configurar el process_mode para que funcione durante la pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Conectar señales de botones
	if prev_button:
		prev_button.pressed.connect(_on_prev_button_pressed)
		print("✅ PrevButton conectado")
	if next_button:
		next_button.pressed.connect(_on_next_button_pressed)
		print("✅ NextButton conectado")
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
		print("✅ CloseButton conectado")
	
	# Hacer clic en el fondo también cierra el visor
	if background:
		background.gui_input.connect(_on_background_input)
	
	print("✅ ContentViewer inicializado")

# Muestra el contenido con el tipo especificado
func show_content(textures: Array[Texture2D], type: UIManager.ContentType = UIManager.ContentType.NOTE) -> void:
	if textures.is_empty():
		push_error("❌ No hay texturas para mostrar")
		return
	
	# IMPORTANTE: Duplicar el array para no modificar el original
	current_textures = textures.duplicate()
	current_page = 0
	current_type = type
	
	# Configurar el tamaño del panel según el tipo
	_configure_panel_for_type(type)
	
	# Actualizar la visualización
	_update_display()
	
	# Pausar el juego y mostrar el visor
	get_tree().paused = true
	
	# Mostrar cursor para interactuar con botones
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	show()
	
	print("📖 Mostrando contenido tipo: ", type, " con ", textures.size(), " página(s)")

# Configura el tamaño y posición del panel según el tipo de contenido
func _configure_panel_for_type(type: UIManager.ContentType) -> void:
	if not PANEL_CONFIGS.has(type):
		push_error("❌ Tipo de contenido no reconocido: ", type)
		return
	
	var config = PANEL_CONFIGS[type]
	var panel_size = config["size"]
	
	# Establecer tamaño del panel
	content_panel.custom_minimum_size = panel_size
	content_panel.size = panel_size
	
	# Centrar el panel en la pantalla
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_pos = (viewport_size - panel_size) / 2 + config["position_offset"]
	content_panel.position = panel_pos
	
	# Posicionar botones dinámicamente
	_position_buttons(panel_size, config)
	
	print("📐 Panel configurado: ", panel_size)

# Posiciona los botones según el tamaño del panel
func _position_buttons(panel_size: Vector2, config: Dictionary) -> void:
	# Botón de cerrar (esquina superior derecha)
	if close_button:
		var close_offset = config["close_button_offset"]
		close_button.position = Vector2(
			panel_size.x + close_offset.x - close_button.size.x,
			close_offset.y
		)
	
	# Botón anterior (esquina inferior izquierda)
	if prev_button:
		var prev_offset = config["prev_button_offset"]
		prev_button.position = Vector2(
			prev_offset.x,
			panel_size.y + prev_offset.y - prev_button.size.y
		)
	
	# Botón siguiente (esquina inferior derecha)
	if next_button:
		var next_offset = config["next_button_offset"]
		next_button.position = Vector2(
			panel_size.x + next_offset.x - next_button.size.x,
			panel_size.y + next_offset.y - next_button.size.y
		)

# Actualiza la visualización de la página actual
func _update_display() -> void:
	if current_page < 0 or current_page >= current_textures.size():
		return
	
	# Actualizar la textura mostrada
	texture_rect.texture = current_textures[current_page]
	
	# Actualizar visibilidad de botones de navegación
	prev_button.visible = current_page > 0
	next_button.visible = current_page < current_textures.size() - 1
	
	print("📄 Página actual: ", current_page + 1, "/", current_textures.size())

# Manejadores de botones
func _on_prev_button_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		_update_display()

func _on_next_button_pressed() -> void:
	if current_page < current_textures.size() - 1:
		current_page += 1
		_update_display()

func _on_close_button_pressed() -> void:
	_close_viewer()

func _on_background_input(_event: InputEvent) -> void:
	# Comentado: No cerrar al hacer clic en el fondo
	# El visor solo se cierra con el botón X o ESC
	pass

# Cierra el visor y reanuda el juego
func _close_viewer() -> void:
	hide()
	get_tree().paused = false
	current_textures.clear()
	current_page = 0
	
	# Ocultar cursor al cerrar el visor (forzar con await)
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	print("❌ ContentViewer cerrado")
	print("🖱️ Cursor oculto: ", Input.mouse_mode == Input.MOUSE_MODE_HIDDEN)

# Permitir cerrar con ESC
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_close_viewer()
		get_viewport().set_input_as_handled()
