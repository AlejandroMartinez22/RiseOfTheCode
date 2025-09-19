# Weapon.gd
extends Resource
class_name Weapon

@export var name: String = "Weapon"
@export var projectile_scene: PackedScene
@export var shoot_sound: AudioStream
@export var shoot_anim_prefix: String = "shoot"   # nombre base de la animación (ej: "shoot")
@export var shoot_speed_scale: float = 1.0        # multiplica speed_scale del AnimatedSprite2D
