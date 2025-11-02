# camera_zone.gd
# Script para Area2D que define límites de cámara específicos
# Usa múltiples de estos en una sala compleja como "Pasillos"
extends Area2D
class_name CameraZone

# ==================== LÍMITES DE ESTA ZONA ====================
@export_group("Límites de Cámara")
@export var zone_left: int = 0
@export var zone_top: int = 0
@export var zone_right: int = 640
@export var zone_bottom: int = 480

# ==================== VISUAL DEBUG ====================
@export var show_debug: bool = true
@export var debug_color: Color = Color(0, 1, 1, 0.3)  # Cyan semi-transparente

func _ready() -> void:
	# Conectar señales
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Configurar para detectar solo al jugador
	collision_layer = 0
	collision_mask = 1  # Layer del jugador

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	# Aplicar límites de esta zona a la cámara
	var camera = body.get_node_or_null("Camera2D")
	if camera:
		camera.limit_left = zone_left
		camera.limit_top = zone_top
		camera.limit_right = zone_right
		camera.limit_bottom = zone_bottom
		
		print("📷 CameraZone '%s' activada" % name)

func _draw() -> void:
	if show_debug:
		# Calcular el rectángulo local basado en los límites
		var local_rect = Rect2(
			zone_left - global_position.x,
			zone_top - global_position.y,
			zone_right - zone_left,
			zone_bottom - zone_top
		)
		draw_rect(local_rect, debug_color, true)
		draw_rect(local_rect, Color.CYAN, false, 2.0)

# Actualizar visual en el editor
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
