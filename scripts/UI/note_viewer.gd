# note_viewer.gd
# Sistema de visualización de notas con soporte para múltiples páginas
extends CanvasLayer

# Referencias a nodos
@onready var background_overlay: ColorRect = $BackgroundOverlay
@onready var note_panel: Panel = $NotePanel
@onready var texture_rect: TextureRect = $NotePanel/TextureRect
@onready var btn_prev: Button = $NotePanel/BtnPrevious
@onready var btn_next: Button = $NotePanel/BtnNext
@onready var btn_close: Button = $NotePanel/BtnClose

# Estado interno
var note_textures: Array[Texture2D] = []
var current_page: int = 0
var is_note_open: bool = false

func _ready() -> void:
	# Asegurar que funcione mientras el juego está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Conectar señales de los botones
	btn_prev.pressed.connect(_on_previous_page)
	btn_next.pressed.connect(_on_next_page)
	btn_close.pressed.connect(_on_close_note)
	
	# Ocultar al inicio
	hide()
	print("✅ NoteViewer inicializado")

func _input(event: InputEvent) -> void:
	# Cerrar con ESC solo si la nota está abierta
	if event.is_action_pressed("pausa") and is_note_open:
		_on_close_note()
		get_viewport().set_input_as_handled()

# Muestra la nota con las texturas proporcionadas
func show_note(textures: Array[Texture2D]) -> void:
	if textures.is_empty():
		push_error("❌ No se proporcionaron texturas para la nota")
		return
	
	print("📖 Mostrando nota con ", textures.size(), " página(s)")
	
	note_textures = textures
	current_page = 0
	is_note_open = true
	
	# Actualizar visualización
	_update_page()
	_update_navigation_buttons()
	
	# Pausar el juego
	get_tree().paused = true
	show()

# Cierra la nota y reanuda el juego
func _on_close_note() -> void:
	print("📕 Cerrando nota")
	is_note_open = false
	get_tree().paused = false
	hide()

# Navega a la página anterior
func _on_previous_page() -> void:
	if current_page > 0:
		current_page -= 1
		_update_page()
		_update_navigation_buttons()

# Navega a la página siguiente
func _on_next_page() -> void:
	if current_page < note_textures.size() - 1:
		current_page += 1
		_update_page()
		_update_navigation_buttons()

# Actualiza la textura mostrada según la página actual
func _update_page() -> void:
	if current_page < note_textures.size():
		texture_rect.texture = note_textures[current_page]
		print("📄 Mostrando página ", current_page + 1, "/", note_textures.size())

# Muestra/oculta los botones de navegación según la página actual
func _update_navigation_buttons() -> void:
	# Solo mostrar botones si hay más de una página
	if note_textures.size() <= 1:
		btn_prev.visible = false
		btn_next.visible = false
		return
	
	# Mostrar/ocultar según la página actual
	btn_prev.visible = current_page > 0
	btn_next.visible = current_page < note_textures.size() - 1
