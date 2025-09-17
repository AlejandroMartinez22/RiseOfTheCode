extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("Algo entró en el arma:", body)
	if body.is_in_group("player"):  # si el cuerpo que entra es el jugador
		print("El jugador recogió el arma") 
		if body.has_method("equip_weapon"):
			body.equip_weapon()  # activa la función del jugador para habilitar disparos
		queue_free()  # elimina el arma del suelo
