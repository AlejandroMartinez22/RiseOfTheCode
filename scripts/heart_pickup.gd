extends PickupItem

# Este código suma vida al jugador sin pasar del máximo.
# Llama al UIManager para refrescar la barra de corazones.
# No hace nada extra si ya está a tope de vida.

@export var heal_amount: int = 10

func on_picked_up(body: Node2D) -> void:
	print("[HeartPickup] recogido por:", body.name, " PlayerData:", PlayerData.current_health, "/", PlayerData.max_health)
	if PlayerData.current_health < PlayerData.max_health:
		PlayerData.current_health = min(PlayerData.current_health + heal_amount, PlayerData.max_health)
		print("[HeartPickup] Jugador curado. Vida actual:", PlayerData.current_health)
	else:
		print("[HeartPickup] Jugador ya está con vida completa")

	# Actualizamos la UI (UIManager lee PlayerData.current_health)
	UIManager.update_hearts()
