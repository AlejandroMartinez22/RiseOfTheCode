# Weapon.gd
extends Resource
class_name Weapon

@export var name: String = "Weapon"
@export var projectile_scene: PackedScene
@export var shoot_sound: AudioStream
@export var shoot_anim_prefix: String = "shoot"
@export var shoot_speed_scale: float = 1.0
@export var pickup_sound: AudioStream   # Campo para manejar el sonido que hará el arma cuando se recoja del suelo
										
