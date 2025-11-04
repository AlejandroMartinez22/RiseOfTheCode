# UIManager.gd
# Gestiona qué UI mostrar según el tipo de interacción
extends CanvasLayer

# Referencias a las UIs que ya están en la escena
@onready var modelo_carta = $ModeloCarta
@onready var modelo_tablero = $ModeloTablero
@onready var modelo_terminal = $ModeloTerminal

var current_ui: Control = null
var is_ui_active: bool = false

func _ready() -> void:
	# Ocultar todas las UIs al inicio
	hide_all_uis()
	layer = 10

func _input(event: InputEvent) -> void:
	# Cerrar UI con E cuando está activa
	if event.is_action_pressed("interact") and is_ui_active:
		hide_current_ui()
		get_viewport().set_input_as_handled()

# Muestra la UI correspondiente según el tipo
func show_ui(ui_type: String, text: String) -> void:
	if is_ui_active:
		return
	
	# Seleccionar qué UI mostrar
	match ui_type:
		"carta":
			current_ui = modelo_carta
		"tablero":
			current_ui = modelo_tablero
		"terminal":
			current_ui = modelo_terminal
		_:
			push_error("Tipo de UI no reconocido: " + ui_type)
			return
	
	if current_ui:
		# Establecer el texto si la UI tiene ese método
		if current_ui.has_method("set_text"):
			current_ui.set_text(text)
		else:
			# Intentar encontrar un Label automáticamente
			set_text_recursive(current_ui, text)
		
		# Mostrar la UI
		current_ui.show()
		is_ui_active = true
		
		# Pausar el juego
		get_tree().paused = true

# Oculta la UI actual
func hide_current_ui() -> void:
	if current_ui:
		current_ui.hide()
		current_ui = null
		is_ui_active = false
		
		# Reanudar el juego
		get_tree().paused = false

# Oculta todas las UIs
func hide_all_uis() -> void:
	if modelo_carta:
		modelo_carta.hide()
	if modelo_tablero:
		modelo_tablero.hide()
	if modelo_terminal:
		modelo_terminal.hide()

# Busca y establece texto en Labels recursivamente
func set_text_recursive(node: Node, text: String) -> bool:
	if node is Label or node is RichTextLabel:
		node.text = text
		return true
	
	for child in node.get_children():
		if set_text_recursive(child, text):
			return true
	
	return false
