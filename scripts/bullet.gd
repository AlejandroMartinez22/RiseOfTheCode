#Se cambió
extends Area2D

@export var data: BulletData #Este es el recurso que utiliza el código para obtener
#el daño y la velocidad del proyectil en cuestión.

@export var target_group: String = ""   # grupo al que este proyectil puede dañar
var direction: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if data == null:
		return

	position += direction * data.speed * delta

	# Si se sale de la pantalla, se destruye
	var viewport_rect = get_viewport_rect()
	if not viewport_rect.has_point(global_position):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if data == null:
		queue_free()
		return

	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(data.damage)
		queue_free()
	else:
		# Choque con algo que no es un objetivo
		queue_free()
