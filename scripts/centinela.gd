extends CharacterBody2D

@onready var player = get_node("/root/main/Max")
@onready var muzzle: Marker2D = $Muzzle
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

@export var data: EnemyData                # Recurso con stats
@export var projectile_scene: PackedScene  # Escena del proyectil
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound  # Sonido de daño

var health: int
var _can_shoot: bool = true
var last_direction: String = "down"  # Dirección inicial por defecto

func _ready() -> void:
	health = data.max_health
	update_animation("idle")  # empezamos en idle_down

func _physics_process(delta: float) -> void:
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	if dist > data.attack_range:
		# Mover hacia el jugador
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * data.speed
		move_and_slide()

		# Actualizar dirección según el vector
		update_direction(dir)
		update_animation("walk")
	else:
		# Parar y disparar
		velocity = Vector2.ZERO
		move_and_slide()

		update_animation("idle")

		if _can_shoot and projectile_scene != null:
			shoot()

# ---------------- Animaciones ----------------
func update_animation(state: String) -> void:
	var anim_name = state + "_" + last_direction

	# ⚠️ Seguridad: solo reproducir si la animación existe
	if animated_sprite.sprite_frames.has_animation(anim_name):
		if animated_sprite.animation != anim_name:
			animated_sprite.play(anim_name)
	else:
		# 👉 fallback mientras no existen todas las animaciones
		if animated_sprite.animation != "idle_down":
			animated_sprite.play("idle_down")

func update_direction(dir: Vector2) -> void:
	# Determina la dirección dominante
	if abs(dir.x) > abs(dir.y):
		last_direction = "right" if dir.x > 0 else "left"
	else:
		last_direction = "down" if dir.y > 0 else "up"

# ---------------- Disparo ----------------
func shoot() -> void:
	var bullet = projectile_scene.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.target_group = "player"
	get_parent().add_child(bullet)

	# Cadencia de disparo
	_can_shoot = false
	await get_tree().create_timer(data.fire_rate).timeout
	_can_shoot = true

# ---------------- Daño ----------------
func take_damage(amount: int) -> void:
	health -= amount

	if hurt_sound.stream != null:
		hurt_sound.play()
	
	# Feedback visual
	animated_sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)
	
	if health <= 0:
		queue_free()
