# interactable.gd
# Sistema de interacción para notas con soporte multi-página
extends Area2D

# Configuración básica
@export var interact_name: String = "presiona E para leer"
@export var is_interactable: bool = true
@export var interact_type: String = "nota"

# Array de texturas para las páginas de la nota
@export var note_pages: Array[Texture2D] = []

# Callable que se ejecuta al interactuar
var interact: Callable = func():
	print("📖 Interactuando con: ", name)
	
	# Validar que hay texturas asignadas
	if note_pages.is_empty():
		push_error("❌ No hay texturas asignadas en note_pages para: " + name)
		return
	
	print("✅ Enviando ", note_pages.size(), " página(s) al UIManager")
	
	# Mostrar la nota a través del UIManager
	UIManager.show_note(note_pages)
