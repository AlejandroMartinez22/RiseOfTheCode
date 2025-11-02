# camera_bounds.gd
# Define los límites de cámara para una sala
# Adjunta este script como hijo de cada sala rectangular
extends Node2D
class_name CameraBounds

# ==================== LÍMITES DE LA SALA ====================
@export_group("Límites de Cámara")
@export var left: int = 0
@export var top: int = 0
@export var right: int = 1920
@export var bottom: int = 1080

# ==================== VISUAL DEBUG ====================
@export var show_debug_rect: bool = true
@export var debug_color: Color = Color(1, 1, 0, 0.2)  # Amarillo semi-transparente

var bounds_rect: Rect2 = Rect2()

func _ready() -> void:
	# Calcular el rectángulo de límites
	bounds_rect = Rect2(left, top, right - left, bottom - top)
	
	# Aplicar límites a la cámara del jugador
	await get_tree().process_frame  # Esperar a que el jugador esté listo
	apply_bounds_to_camera()
	
	print("📷 CameraBounds aplicado: L=%d T=%d R=%d B=%d" % [left, top, right, bottom])

func apply_bounds_to_camera() -> void:
	# Buscar la cámara del jugador
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() == 0:
		push_warning("CameraBounds: No se encontró jugador")
		return
	
	var player = players[0]
	var camera = player.get_node_or_null("Camera2D")
	
	if camera:
		camera.limit_left = left
		camera.limit_top = top
		camera.limit_right = right
		camera.limit_bottom = bottom
		
		print("✅ Límites aplicados a cámara")
	else:
		push_warning("CameraBounds: Player no tiene Camera2D")

func _draw() -> void:
	if show_debug_rect:
		# Dibujar rectángulo de debug
		var local_rect = Rect2(left, top, right - left, bottom - top)
		draw_rect(local_rect, debug_color, true)
		draw_rect(local_rect, Color.YELLOW, false, 3.0)

# Actualizar visual en tiempo real cuando cambias valores en el editor
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		bounds_rect = Rect2(left, top, right - left, bottom - top)
		queue_redraw()

# Función para obtener los límites actuales
func get_bounds() -> Rect2:
	return Rect2(left, top, right - left, bottom - top)
