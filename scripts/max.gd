extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@export var projectile_scene: PackedScene   # asignar red_bullet.tscn en el editor

var speed: float = 100.0
var last_direction: String = "down"
var has_weapon: bool = false

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

	# Si tiene arma y presiona K → dispara
	if has_weapon and Input.is_action_just_pressed("shoot"):
		# Animación de disparo (por ahora solo hacia abajo)
		if last_direction == "down":
			animated_sprite.play("shoot_down")
		# Aquí después puedes añadir más direcciones
		shoot()

# ----------------- Input -----------------
func get_input() -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")

	if input_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		update_animation("idle")
		return

	if abs(input_direction.x) > abs(input_direction.y):
		if input_direction.x > 0:
			last_direction = "right"
		else:
			last_direction = "left"
	else:
		if input_direction.y > 0:
			last_direction = "down"
		else:
			last_direction = "up"

	update_animation("walk")
	velocity = input_direction * speed

# ----------------- Animaciones -----------------
func update_animation(state: String) -> void:
	animated_sprite.play(state + "_" + last_direction)

# ----------------- Arma y disparo -----------------
func equip_weapon() -> void:
	has_weapon = true

func shoot() -> void:
	if projectile_scene == null:
		push_error("❌ projectile_scene no asignado en el inspector.")
		return

	var bullet = projectile_scene.instantiate()
	bullet.global_position = global_position
	match last_direction:
		"right":
			bullet.direction = Vector2.RIGHT
		"left":
			bullet.direction = Vector2.LEFT
		"up":
			bullet.direction = Vector2.UP
		"down":
			bullet.direction = Vector2.DOWN
	get_parent().add_child(bullet)
