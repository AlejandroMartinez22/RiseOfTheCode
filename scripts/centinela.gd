# Centinela.gd
extends CharacterBody2D

@onready var player = get_node("/root/main/Max")
@onready var muzzle: Marker2D = $Muzzle

@export var data: EnemyData        # Recurso con stats
@export var projectile_scene: PackedScene   # Escena del proyectil

var health: int
var _can_shoot: bool = true

func _ready() -> void:
	# Inicializamos la vida con el valor del recurso
	health = data.max_health

func _physics_process(delta: float) -> void:
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	if dist > data.attack_range:
		# El jugador está lejos → moverse hacia él
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * data.speed
		move_and_slide()
	else:
		# El jugador está cerca → detenerse y disparar
		velocity = Vector2.ZERO
		move_and_slide()

		if _can_shoot and projectile_scene != null:
			shoot()

func shoot() -> void:
	var bullet = projectile_scene.instantiate()

	bullet.global_position = muzzle.global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.target_group = "player"

	get_parent().add_child(bullet)

	# Control de cadencia
	_can_shoot = false
	await get_tree().create_timer(data.fire_rate).timeout
	_can_shoot = true

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
