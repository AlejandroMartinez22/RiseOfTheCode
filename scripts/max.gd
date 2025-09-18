extends CharacterBody2D

#Markers para definir de donde sale el proyectil al disparar.
@onready var muzzle_down: Marker2D = $MuzzleDown
@onready var muzzle_right: Marker2D = $MuzzleRight
@onready var muzzle_left: Marker2D = $MuzzleLeft
@onready var muzzle_up: Marker2D = $MuzzleUp


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@export var projectile_scene: PackedScene   # asignar red_bullet.tscn en el editor

var speed: float = 100.0
var last_direction: String = "down"
var has_weapon: bool = false
var is_shooting: bool = false   # controla si está en animación de disparo

func _ready() -> void:
	# Conectamos la señal para detectar cuando termina la animación
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	# 🚫 Mientras dispara, no puede moverse ni disparar otra vez
	if is_shooting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# 🚶 Movimiento normal
	get_input()
	move_and_slide()

	# Disparo (solo si no está disparando ya)
	if has_weapon and Input.is_action_just_pressed("shoot"):
		match last_direction:
			"down":
				animated_sprite.play("shoot_down")
			"right":
				animated_sprite.play("shoot_right")
			"left":
				animated_sprite.play("shoot_left")
			"up":
				animated_sprite.play("shoot_up") # fallback por ahora
		is_shooting = true
		velocity = Vector2.ZERO  # detenerse al disparar
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
	if not is_shooting:  # evita que idle/walk sobreescriba el disparo
		animated_sprite.play(state + "_" + last_direction)

# ----------------- Arma y disparo -----------------
func equip_weapon() -> void:
	has_weapon = true

func shoot() -> void:
	if projectile_scene == null:
		push_error("❌ projectile_scene no asignado en el inspector.")
		return

	var bullet = projectile_scene.instantiate()

	match last_direction:
		"right":
			bullet.global_position = muzzle_right.global_position
			bullet.direction = Vector2.RIGHT
		"left":
			bullet.global_position = muzzle_left.global_position
			bullet.direction = Vector2.LEFT
		"up":
			bullet.global_position = muzzle_up.global_position
			bullet.direction = Vector2.UP
		"down":
			bullet.global_position = muzzle_down.global_position
			bullet.direction = Vector2.DOWN

	get_parent().add_child(bullet)

# ----------------- Callback -----------------
func _on_animation_finished() -> void:
	if animated_sprite.animation in ["shoot_down", "shoot_right", "shoot_left", "shoot_up"]:
		is_shooting = false
		update_animation("idle")
