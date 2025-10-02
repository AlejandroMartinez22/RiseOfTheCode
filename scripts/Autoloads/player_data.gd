extends Node

var max_health: int = 30
var current_health: int = 30
var current_weapon: String = ""

func reset() -> void:
	max_health = 30
	current_health = max_health
	current_weapon = ""
