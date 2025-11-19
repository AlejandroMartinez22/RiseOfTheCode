# Configuración de spawns de enemigos para el puzzle del laboratorio
extends Node

static func get_enemy_spawns() -> Array[Dictionary]:
	var centinela = load("res://scenes/enemies/centinela.tscn")
	
	var spawns: Array[Dictionary] = []
	
	# PASILLOS
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/pasillos.tscn",
		"position": Vector2(882, 391),
		"enemy_id": "centinela_pasillo_01"
	})
	
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/pasillos.tscn",
		"position": Vector2(1267, 390),
		"enemy_id": "centinela_recepcion_02"
	})


	# ... más spawns
	
	return spawns
