# Configuración de spawns de enemigos para el puzzle del laboratorio
extends Node

static func get_enemy_spawns() -> Array[Dictionary]:
	var centinela = load("res://scenes/enemies/centinela.tscn")
	
	var spawns: Array[Dictionary] = []
	
	# PASILLOS
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/pasillos.tscn",
		"position": Vector2(499, 391),
		"enemy_id": "centinela_pasillo_01"
	})
	
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/pasillos.tscn",
		"position": Vector2(1267, 391),
		"enemy_id": "centinela_pasillo_02"
	})
	
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/pasillos.tscn",
		"position": Vector2(499, 7),
		"enemy_id": "centinela_pasillo_03"
	})
	
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/pasillos.tscn",
		"position": Vector2(1267, 7),
		"enemy_id": "centinela_pasillo_04"
	})
	
	# SALONES
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/salon_101.tscn",
		"position": Vector2(39, 125),
		"enemy_id": "centinela_salon101"
	})
	
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/salon_202.tscn",
		"position": Vector2(53, 148),
		"enemy_id": "centinela_salon202"
	})
	
	#RECEPCION
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/recepcion.tscn",
		"position": Vector2(96, 95),
		"enemy_id": "centinela_recepcion_1"
	})
	
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/recepcion.tscn",
		"position": Vector2(287, 95),
		"enemy_id": "centinela_recepcion_2"
	})
	
	#LAB_ROBOTICA
	spawns.append({
		"scene": centinela,
		"room_path": "res://scenes/map/level1/lab_robotica.tscn",
		"position": Vector2(159, 79),
		"enemy_id": "centinela_lab_robotica"
	})
	
	
	return spawns
