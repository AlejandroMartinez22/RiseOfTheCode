extends Area2D

@export var weapon_data: Weapon

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("equip_weapon"):
			body.equip_weapon(weapon_data)

		# sonido de pickup desde el recurso
		if weapon_data.pickup_sound != null:
			AudioManager.play_sound(weapon_data.pickup_sound, global_position)

		queue_free()
