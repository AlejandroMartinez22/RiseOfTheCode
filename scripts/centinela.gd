# Enemy.gd
extends CharacterBody2D

@onready var player = get_node("/root/main/Max")
@export var speed: float = 20.0
@export var attack_range: float = 120.0
@export var fire_rate: float = 1.5          # segundos entre disparos
@export var projectile_scene: PackedScene  # Asignar en el Inspector (arrastrando la .tscn)

var _can_shoot: bool = true

func _physics_process(delta: float) -> void:
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	if dist > attack_range:
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		if _can_shoot and projectile_scene != null:
			shoot()

func shoot() -> void:
	var bullet = projectile_scene.instantiate()
	# Puedes usar un Marker2D llamado "Muzzle" si quieres que salga desde la punta
	# bullet.global_position = $Muzzle.global_position
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	get_parent().add_child(bullet)

	_can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	_can_shoot = true
