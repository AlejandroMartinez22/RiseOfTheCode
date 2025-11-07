# interactable.gd
# Sistema de interacción para elementos de texto con soporte multi-página
extends Area2D

# Configuración básica
@export var interact_name: String = "presiona E para leer"
@export var is_interactable: bool = true

# Tipo de interacción (nota, tablero, computador)
@export_enum("nota", "tablero", "computador") var interact_type: String = "nota"

# Array de texturas para las páginas del contenido
@export var content_pages: Array[Texture2D] = []

# Callable que se ejecuta al interactuar
var interact: Callable = func():
	print("📖 Interactuando con: ", name, " (", interact_type, ")")
	
	# Validar que hay texturas asignadas
	if content_pages.is_empty():
		push_error("❌ No hay texturas asignadas en content_pages para: " + name)
		return
	
	print("✅ Enviando ", content_pages.size(), " página(s) al UIManager")
	
	# Determinar el tipo de contenido según interact_type
	var content_type: UIManager.ContentType
	match interact_type:
		"nota":
			content_type = UIManager.ContentType.NOTE
		"tablero":
			content_type = UIManager.ContentType.BOARD
		"computador":
			content_type = UIManager.ContentType.COMPUTER
		_:
			content_type = UIManager.ContentType.NOTE
	
	# Mostrar el contenido a través del UIManager
	UIManager.show_content(content_pages, content_type)
