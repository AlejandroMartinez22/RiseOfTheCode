# camera_zone.gd
# Sistema de zonas de cámara con prioridad para pasillos complejos
# Usa áreas grandes que cubran cada pasillo completo
extends Area2D
class_name CameraZone

# ==================== LÍMITES DE ESTA ZONA ====================
@export_group("Límites de Cámara")
@export var zone_name: String = "Pasillo1"
@export var zone_left: int = 0
@export var zone_top: int = 0
@export var zone_right: int = 640
@export var zone_bottom: int = 480

# ==================== SISTEMA DE PRIORIDAD ====================
@export_group("Prioridad")
@export var zone_priority: int = 0  # Mayor número = mayor prioridad (útil en intersecciones)

# ==================== TRANSICIÓN SUAVE ====================
@export_group("Transición")
@export var smooth_transition: bool = true
@export var transition_speed: float = 5.0

# ==================== ZOOM OPCIONAL ====================
@export_group("Zoom (Opcional)")
@export var override_zoom: bool = false
@export var zone_zoom: Vector2 = Vector2(1.3, 1.3)

# ==================== VARIABLES INTERNAS ====================
var player_inside: bool = false
var is_active: bool = false

# Referencia estática a la zona actualmente activa
static var current_active_zone: CameraZone = null

func _ready() -> void:
	# Conectar señales
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Configurar capas de colisión
	collision_layer = 0
	collision_mask = 1
	
	add_to_group("camera_zones")

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_inside = true
	check_and_activate(body)

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_inside = false
	
	if is_active:
		is_active = false
		if current_active_zone == self:
			current_active_zone = null
		
		# Buscar otra zona donde esté el jugador
		var all_zones = get_tree().get_nodes_in_group("camera_zones")
		var candidate_zone: CameraZone = null
		
		for zone in all_zones:
			if zone is CameraZone and zone.player_inside and zone != self:
				if candidate_zone == null or zone.zone_priority > candidate_zone.zone_priority:
					candidate_zone = zone
		
		if candidate_zone:
			candidate_zone.check_and_activate(body)

func check_and_activate(body: Node) -> void:
	# Verificar si hay zonas con mayor prioridad donde también esté el jugador
	var all_zones = get_tree().get_nodes_in_group("camera_zones")
	
	for zone in all_zones:
		if zone is CameraZone and zone != self and zone.player_inside:
			if zone.zone_priority > zone_priority:
				return
	
	# Esta zona tiene la mayor prioridad, activarla
	activate(body)

func activate(body: Node) -> void:
	# Desactivar zona anterior si existe
	if current_active_zone != null and current_active_zone != self:
		current_active_zone.is_active = false
	
	# Activar esta zona
	is_active = true
	current_active_zone = self
	
	# Aplicar límites
	apply_camera_limits(body)

func apply_camera_limits(body: Node) -> void:
	var camera = body.get_node_or_null("Camera2D")
	if not camera:
		push_warning("CameraZone: Player no tiene Camera2D")
		return
	
	if smooth_transition:
		apply_smooth_limits(camera)
	else:
		camera.limit_left = zone_left
		camera.limit_top = zone_top
		camera.limit_right = zone_right
		camera.limit_bottom = zone_bottom
		
		if override_zoom:
			camera.zoom = zone_zoom
	
	print("📷 CameraZone '%s' activada [Prioridad: %d]" % [zone_name, zone_priority])

func apply_smooth_limits(camera: Camera2D) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	var duration = 1.0 / transition_speed
	
	tween.tween_property(camera, "limit_left", zone_left, duration)
	tween.tween_property(camera, "limit_top", zone_top, duration)
	tween.tween_property(camera, "limit_right", zone_right, duration)
	tween.tween_property(camera, "limit_bottom", zone_bottom, duration)
	
	if override_zoom:
		tween.tween_property(camera, "zoom", zone_zoom, duration)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if zone_name.is_empty():
		warnings.append("Configura 'zone_name' para identificar esta zona")
	
	if zone_right <= zone_left:
		warnings.append("zone_right debe ser mayor que zone_left")
	
	if zone_bottom <= zone_top:
		warnings.append("zone_bottom debe ser mayor que zone_top")
	
	var collision_shape = get_node_or_null("CollisionShape2D")
	if not collision_shape:
		warnings.append("Falta agregar un CollisionShape2D como hijo")
	
	return warnings
