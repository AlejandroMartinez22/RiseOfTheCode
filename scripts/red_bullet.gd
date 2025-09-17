extends Area2D

@export var speed: float = 200.0   # Velocidad de la bala
@export var damage: int = 10       # Daño que hace la bala
var direction: Vector2 = Vector2.ZERO  # Dirección en la que se moverá

func _process(delta: float) -> void:
	# Mueve el proyectil en la dirección asignada
	position += direction * speed * delta

	# Si se sale de la pantalla, se destruye para no gastar recursos
	var viewport_rect = get_viewport_rect()
	if not viewport_rect.has_point(global_position):
		queue_free()

# Se ejecuta cuando choca contra algo
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):  # Si el objeto pertenece al grupo "enemies"
		if body.has_method("take_damage"):
			body.take_damage(damage)  # Aplica daño al enemigo
		queue_free()  # La bala desaparece
	else:
		# Si choca con cualquier otra cosa (pared, obstáculo, etc.)
		queue_free()
