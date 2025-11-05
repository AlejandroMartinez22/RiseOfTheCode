# ui_manager.gd
# Singleton encargado de gestionar los elementos de la interfaz de usuario.
extends Node 

var heart_container: Node = null
var note_viewer: CanvasLayer = null

# Actualiza la visualización de los corazones en la interfaz de usuario.
func update_hearts() -> void:
	if heart_container != null:
		heart_container.update_hearts(PlayerData.current_health)

# Registra el visor de notas
func register_note_viewer(viewer: CanvasLayer) -> void:
	note_viewer = viewer
	print("✅ NoteViewer registrado en UIManager")

# Muestra una nota con las texturas especificadas
func show_note(textures: Array[Texture2D]) -> void:
	if note_viewer:
		note_viewer.show_note(textures)
	else:
		push_error("❌ NoteViewer no está registrado en UIManager")
