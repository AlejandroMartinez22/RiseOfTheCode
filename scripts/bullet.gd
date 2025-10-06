# Script genérico para proyectiles 
# Controla movimiento, alcance, colisiones y aplicación de daño.

extends Area2D

@export var data: BulletData       # Recurso con la información del proyectil 
@export var target_group: String = ""   # Grupo objetivo: "enemies" o "player"
@export var max_distance: float = 1000.0  # Distancia máxima antes de destruirse


var direction: Vector2 = Vector2.ZERO # Dirección del movimiento
var start_position: Vector2    # Posición inicial del proyectil


# Inicializa la bala, guarda su posición inicial y asegura la conexión de señales.
func _ready() -> void:
	start_position = global_position

	# Habilitar monitoreo de colisiones
	monitoring = true
	monitorable = true

	# Conectar señales dinámicamente (por si no están conectadas en el editor)
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))


# Actualiza el movimiento del proyectil y verifica si excede su rango máximo.
func _process(delta: float) -> void:
	if data == null:
		return
	
	# Mover el proyectil en línea recta
	position += direction * data.speed * delta

	# Destruir si supera la distancia máxima
	if global_position.distance_to(start_position) > max_distance:
		queue_free()



# Se ejecuta cuando el proyectil colisiona con un PhysicsBody2D (enemigo, jugador, pared, etc.).
func _on_body_entered(body: Node) -> void:
	if target_group == "":
		queue_free()
		return

	# Si el objeto pertenece al grupo objetivo, aplicamos daño
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(data.damage)
		queue_free()
	else:
		# Si choca con cualquier otro objeto (pared, suelo, etc.)
		queue_free()


# Similar a _on_body_entered, pero para colisiones con otras áreas.
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
