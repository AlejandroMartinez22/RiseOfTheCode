# Clase base para todos los enemigos del juego.
# Define comportamientos comunes, evitando duplicar código en cada tipo de enemigo.

extends CharacterBody2D
class_name EnemyBase

@export var data: EnemyData   # Recurso con los atributos configurables del enemigo 
@export var heart_pickup_scene: PackedScene  # Escena del objeto corazón que puede soltar el enemigo


# Lógica genérica para determinar si el enemigo suelta un corazón al morir.
# Usa la probabilidad definida en el recurso 'EnemyData'.
func maybe_drop_heart() -> void:
	if heart_pickup_scene == null or data == null:
		return

	# Obtener la probabilidad de drop (valor entre 0.0 y 1.0)
	var drop_chance := data.heart_drop_chance

	# randf() genera un número aleatorio entre 0.0 y 1.0
	# Si el valor cae dentro del rango de probabilidad, se instancia el corazón
	if randf() <= drop_chance:
		var heart = heart_pickup_scene.instantiate()
		heart.global_position = global_position
		get_parent().add_child(heart)
