extends PickupItem
# Clase que representa un objeto recogible de tipo arma.
# Hereda de `PickupItem`, aprovechando su detección automática de colisiones y sonido de recogida.

@export var weapon_data: Weapon  # Datos del arma que será equipada al jugador

# EVENTO DE RECOGIDA (sobrescribe método de PickupItem)
func on_picked_up(body: Node2D) -> void:
	# Si el cuerpo (body) tiene un método "equip_weapon", se le asigna el arma.
	if body.has_method("equip_weapon"):
		body.equip_weapon(weapon_data)
