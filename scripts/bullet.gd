extends Area2D

@export var data: BulletData
@export var target_group: String = ""   # "enemies" o "player"
@export var max_distance: float = 1000.0   # distancia máxima antes de destruirse

var direction: Vector2 = Vector2.ZERO
var start_position: Vector2

func _ready() -> void:
	# Guardar posición inicial
	start_position = global_position

	# Asegurarnos de que el Area2D vigila colisiones
	monitoring = true
	monitorable = true

	# Conectar señales en caso de que no lo hayas hecho desde el editor
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	if data == null:
		return
	position += direction * data.speed * delta

	# destruir si supera la distancia máxima desde el punto de origen
	if global_position.distance_to(start_position) > max_distance:
		queue_free()

# Cuando choca con un PhysicsBody2D (p. ej. CharacterBody2D)
func _on_body_entered(body: Node) -> void:
	# Si no hay target definido, destruimos la bala
	if target_group == "":
		queue_free()
		return

	# Solo aplicamos daño si el body pertenece al grupo objetivo
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(data.damage)
		queue_free()
	else:
		# Si choca con otra cosa (pared, suelo, obstáculo), también se destruye
		queue_free()

# Cuando choca con otra Area2D (por si usas áreas para colisiones)
func _on_area_entered(area: Area2D) -> void:
	if target_group == "":
		queue_free()
		return

	if area.is_in_group(target_group):
		if area.has_method("take_damage"):
			area.take_damage(data.damage)
		queue_free()
	else:
		queue_free()
