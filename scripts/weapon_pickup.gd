extends Area2D

@export var weapon_data: Weapon

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("equip_weapon"):
			body.equip_weapon(weapon_data)

		#  Le pedimos al jugador que reproduzca el sonido de recogida
		if body.has_method("play_pickup_sound"):
			body.play_pickup_sound()

		queue_free()  # el arma desaparece al instante
