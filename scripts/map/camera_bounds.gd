# camera_bounds.gd
# Define los límites de cámara para una sala
# Ahora con soporte para ajustar zoom en salas pequeñas
extends Node2D
class_name CameraBounds

# ==================== LÍMITES DE LA SALA ====================
@export_group("Límites de Cámara")
@export var left: int = 0
@export var top: int = 0
@export var right: int = 1920
@export var bottom: int = 1080

# ==================== ZOOM ====================
@export_group("Configuración de Zoom")
@export var use_custom_zoom: bool = false  # Si quieres zoom específico para esta sala
@export var custom_zoom: Vector2 = Vector2(1.3, 1.3)  # Zoom personalizado
@export var auto_adjust_zoom: bool = true  # Ajustar zoom automáticamente si sala es pequeña

# ==================== VISUAL DEBUG ====================
@export_group("Debug")
@export var show_debug_rect: bool = true
@export var debug_color: Color = Color(1, 1, 0, 0.2)

# ==================== VARIABLES INTERNAS ====================
var bounds_rect: Rect2 = Rect2()
var original_zoom: Vector2 = Vector2(1.3, 1.3)  # Zoom por defecto del juego

func _ready() -> void:
	# Calcular el rectángulo de límites
	bounds_rect = Rect2(left, top, right - left, bottom - top)
	
	# Aplicar límites a la cámara del jugador
	await get_tree().process_frame
	apply_bounds_to_camera()
	
	print("📷 CameraBounds aplicado: L=%d T=%d R=%d B=%d" % [left, top, right, bottom])

func apply_bounds_to_camera() -> void:
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() == 0:
		push_warning("CameraBounds: No se encontró jugador")
		return
	
	var player = players[0]
	var camera = player.get_node_or_null("Camera2D")
	
	if not camera:
		push_warning("CameraBounds: Player no tiene Camera2D")
		return
	
	# Guardar zoom original si es la primera vez
	if original_zoom == Vector2(1.3, 1.3):
		original_zoom = camera.zoom
	
	# Calcular dimensiones de la sala
	var room_width = right - left
	var room_height = bottom - top
	
	# Obtener tamaño del viewport
	var viewport_size = get_viewport_rect().size
	
	# Determinar el zoom a usar
	var target_zoom: Vector2
	
	if use_custom_zoom:
		# Usar zoom personalizado configurado manualmente
		target_zoom = custom_zoom
		print("🔍 Usando zoom personalizado: ", custom_zoom)
	
	elif auto_adjust_zoom:
		# Calcular zoom necesario para salas pequeñas
		target_zoom = calculate_optimal_zoom(room_width, room_height, viewport_size, camera.zoom)
	
	else:
		# Usar zoom por defecto
		target_zoom = original_zoom
	
	# Aplicar zoom
	camera.zoom = target_zoom
	
	# Aplicar límites
	camera.limit_left = left
	camera.limit_top = top
	camera.limit_right = right
	camera.limit_bottom = bottom
	
	print("✅ Límites aplicados | Zoom: ", camera.zoom)

func calculate_optimal_zoom(room_width: float, room_height: float, viewport_size: Vector2, current_zoom: Vector2) -> Vector2:
	# Calcular cuánto ve la cámara con el zoom actual
	var visible_width = viewport_size.x / current_zoom.x
	var visible_height = viewport_size.y / current_zoom.y
	
	# Si la sala es más pequeña que lo visible, aumentar zoom
	var zoom_x = current_zoom.x
	var zoom_y = current_zoom.y
	
	if room_width < visible_width:
		# Calcular zoom necesario para que la sala llene el ancho
		zoom_x = viewport_size.x / room_width
		# Agregar un pequeño margen (5%)
		zoom_x *= 0.95
		print("⚠️ Sala estrecha: ajustando zoom X de %.2f a %.2f" % [current_zoom.x, zoom_x])
	
	if room_height < visible_height:
		# Calcular zoom necesario para que la sala llene el alto
		zoom_y = viewport_size.y / room_height
		# Agregar un pequeño margen (5%)
		zoom_y *= 0.95
		print("⚠️ Sala baja: ajustando zoom Y de %.2f a %.2f" % [current_zoom.y, zoom_y])
	
	# Usar el zoom más grande de los dos (para que todo quepa)
	var final_zoom = max(zoom_x, zoom_y)
	
	# Limitar el zoom máximo para evitar acercar demasiado
	final_zoom = min(final_zoom, 2.5)  # No más de 2.5x
	
	# Si no necesita ajuste, usar el zoom original
	if final_zoom == current_zoom.x and final_zoom == current_zoom.y:
		return current_zoom
	
	return Vector2(final_zoom, final_zoom)

func _draw() -> void:
	if show_debug_rect:
		var local_rect = Rect2(left, top, right - left, bottom - top)
		draw_rect(local_rect, debug_color, true)
		draw_rect(local_rect, Color.YELLOW, false, 3.0)
		
		# Dibujar dimensiones
		var center = local_rect.get_center()
		var size_text = "%dx%d" % [local_rect.size.x, local_rect.size.y]
		# Nota: draw_string requiere una fuente, mejor usar print en consola

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		bounds_rect = Rect2(left, top, right - left, bottom - top)
		queue_redraw()

func get_bounds() -> Rect2:
	return Rect2(left, top, right - left, bottom - top)
