extends Node

var heart_container: Node = null

func update_hearts() -> void:
	if heart_container != null:
		# UIManager lee el valor desde PlayerData
		heart_container.update_hearts(PlayerData.current_health)
