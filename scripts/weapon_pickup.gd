extends PickupItem

@export var weapon_data: Weapon

func on_picked_up(body: Node2D) -> void:
	if body.has_method("equip_weapon"):
		body.equip_weapon(weapon_data)
