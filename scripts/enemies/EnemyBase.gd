#Este script agrupa comportamientos comunes que tienen los enemigos, para evitar duplicar código.
#De momento solo contiene la lógica relacionada al drop de corazón, una vez que el enemigo muere.

extends CharacterBody2D
class_name EnemyBase

@export var data: EnemyData
@export var heart_pickup_scene: PackedScene

# Función genérica de drop de corazón
func maybe_drop_heart() -> void:
	if heart_pickup_scene == null or data == null:
		return

	var drop_chance := data.heart_drop_chance
	if randf() <= drop_chance:
		var heart = heart_pickup_scene.instantiate()
		heart.global_position = global_position
		get_parent().add_child(heart)
