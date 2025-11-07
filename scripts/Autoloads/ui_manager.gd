# ui_manager.gd
# Singleton encargado de gestionar los elementos de la interfaz de usuario.
extends Node 

# Enumeración para los tipos de contenido
enum ContentType {
	NOTE,
	BOARD,
	COMPUTER
}

var heart_container: Node = null
var content_viewer: CanvasLayer = null

# Actualiza la visualización de los corazones en la interfaz de usuario.
func update_hearts() -> void:
	if heart_container != null:
		heart_container.update_hearts(PlayerData.current_health)

# Registra el visor de contenido (antes note_viewer)
func register_content_viewer(viewer: CanvasLayer) -> void:
	content_viewer = viewer
	print("✅ ContentViewer registrado en UIManager")

# Muestra contenido con las texturas especificadas y tipo
func show_content(textures: Array[Texture2D], type: ContentType = ContentType.NOTE) -> void:
	if content_viewer:
		content_viewer.show_content(textures, type)
	else:
		push_error("❌ ContentViewer no está registrado en UIManager")
