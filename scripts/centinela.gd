# Centinela.gd
extends CharacterBody2D

@onready var player = get_node("/root/main/Max")
@onready var muzzle: Marker2D = $Muzzle

@export var speed: float = 20.0                 # Velocidad de movimiento
@export var attack_range: float = 120.0         # Distancia mínima para dejar de avanzar y disparar
@export var fire_rate: float = 1.8            # Segundos entre disparos
@export var projectile_scene: PackedScene       # Escena del proyectil (ej: enemy_bullet.tscn)

var _can_shoot: bool = true

func _physics_process(delta: float) -> void:
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	if dist > attack_range:
		# El jugador está lejos → moverse hacia él
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
		move_and_slide()
	else:
		# El jugador está cerca → detenerse y disparar
		velocity = Vector2.ZERO
		move_and_slide()

		if _can_shoot and projectile_scene != null:
			shoot()

func shoot() -> void:
	var bullet = projectile_scene.instantiate()

	# Punto de origen del disparo (si quieres usar un Marker2D en el Centinela, cámbialo aquí)
	bullet.global_position = muzzle.global_position

	# Dirección hacia el jugador
	bullet.direction = (player.global_position - global_position).normalized()

	# ⚠️ Muy importante: los proyectiles del Centinela dañan al jugador
	bullet.target_group = "player"

	get_parent().add_child(bullet)

	# Control de cadencia de disparo
	_can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	_can_shoot = true
