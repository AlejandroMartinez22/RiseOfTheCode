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
var is_dead: bool = false            # bandera para no repetir la muerte

func _ready() -> void:
	health = data.max_health
	update_animation()  # empezamos en idle_down

func _physics_process(delta: float) -> void:
	if is_dead:
		return

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
		update_animation()
	else:
		# Parar y disparar
		velocity = Vector2.ZERO
		move_and_slide()

		update_animation()

		if _can_shoot and projectile_scene != null:
			shoot()

# ---------------- Animaciones ----------------
func update_animation() -> void:
	if is_dead:
		return  # no cambiar animaciones si ya está muerto

	var anim_name = "idle_" + last_direction

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
	if is_dead:
		return

	health -= amount

	if hurt_sound.stream != null:
		hurt_sound.play()
	
	# Feedback visual
	animated_sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)
	
	if health <= 0:
		die()

# ---------------- Muerte ----------------
func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	_can_shoot = false

	# Animación de muerte según dirección
	var death_anim = "death_" + last_direction
	if animated_sprite.sprite_frames.has_animation(death_anim):
		animated_sprite.play(death_anim)
	else:
		# fallback mientras solo existe death_down
		animated_sprite.play("death_down")

	# Conectar al finalizar la animación
	animated_sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"), CONNECT_ONE_SHOT)

func _on_death_animation_finished() -> void:
	queue_free()
