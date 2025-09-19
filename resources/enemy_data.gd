# EnemyData.gd
extends Resource
class_name EnemyData

@export var max_health: int = 10
@export var speed: float = 50.0
@export var attack_range: float = 120.0 #Rango para que el enemigo ataque, que tan lejos o cerca puede atacar
@export var fire_rate: float = 1.5
@export var damage: int = 2   # ⚠️ Para melee o explosivos (los que no disparan)
