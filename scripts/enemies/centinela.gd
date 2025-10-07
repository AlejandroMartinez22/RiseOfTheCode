# Dron que detecta al jugador, lo persigue dentro de un rango
# y dispara proyectiles. Hereda de EnemyBase, lo que le da atributos como
# velocidad, vida, y posibilidad de soltar corazones al morir.

extends EnemyBase

# ------------------ Referencias a Nodos ------------------
@onready var muzzle: Marker2D = $Muzzle  # Punto desde donde salen los disparos
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var detection_area: Area2D = $DetectionArea

# ------------------ Escenas Exportadas ------------------
@export var projectile_scene: PackedScene  #Escena de la bala que dispara

# ------------------ Sonidos ------------------
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound

# ------------------ Parámetros de comportamiento ------------------
@export var stick_on_detection: bool = true    # Si es true, sigue atacando al jugador aunque salga del área
@export var smoothing_factor: float = 0.0      # Suaviza el movimiento de rotación o dirección (0 = instantáneo)
@export var explosion_radius: float = 32.0     # Radio de daño al morir
@export var explosion_damage: int = 10         # Daño causado por la explosión

# ------------------ Variables internas ------------------
var player: Node = null
var health: int
var _can_shoot: bool = true
var last_direction: String = "down"
var is_dead: bool = false
var detected: bool = false


# FUNCIÓN READY
func _ready() -> void:
	health = data.max_health
	update_animation()

	# Buscar jugador
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

	# Conectar señales de detección solo si no están conectadas
	if detection_area and not detection_area.is_connected("body_entered", Callable(self, "_on_detection_body_entered")):
		detection_area.connect("body_entered", Callable(self, "_on_detection_body_entered"))
	if detection_area and not detection_area.is_connected("body_exited", Callable(self, "_on_detection_body_exited")):
		detection_area.connect("body_exited", Callable(self, "_on_detection_body_exited"))



# PROCESO PRINCIPAL -> Movimiento, detección y disparo

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Si no hay referencia al jugador, volver a buscarlo
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	# Si no ha detectado al jugador, se queda quieto
	if not detected or player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation()
		return

	# Calcular dirección hacia el jugador
	var dir = global_position.direction_to(player.global_position)
	var look_dir = (player.global_position - global_position).normalized()
	var final_dir = dir.lerp(look_dir, clamp(smoothing_factor, 0.0, 1.0)) if smoothing_factor > 0.0 else dir

	var dist = global_position.distance_to(player.global_position)

	# Si el jugador está fuera del rango de ataque → moverse hacia él
	if dist > data.attack_range:
		velocity = dir * data.speed
		move_and_slide()
		update_direction(final_dir)
		update_animation()
	else:
		# Dentro del rango → detenerse y atacar
		velocity = Vector2.ZERO
		move_and_slide()
		update_direction(final_dir)
		update_animation()
		if _can_shoot and projectile_scene != null:
			shoot()


# ANIMACIONES
func update_animation() -> void:
	if is_dead:
		return
	var anim_name = "idle_" + last_direction
	if animated_sprite.sprite_frames.has_animation(anim_name):
		if animated_sprite.animation != anim_name:
			animated_sprite.play(anim_name)
	else:
		if animated_sprite.animation != "idle_down":
			animated_sprite.play("idle_down")

func update_direction(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		last_direction = "right" if dir.x > 0 else "left"
	else:
		last_direction = "down" if dir.y > 0 else "up"


# ATAQUE (DISPARO)
func shoot() -> void:
	_can_shoot = false
	var bullet = projectile_scene.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.target_group = "player"
	get_parent().add_child(bullet)

	if shoot_sound.stream != null:
		AudioManager.play_sound(shoot_sound.stream, global_position, -5)

	await get_tree().create_timer(data.fire_rate).timeout
	_can_shoot = true


# DETECCIÓN DE JUGADOR
func _on_detection_body_entered(body: Node) -> void:
	if body == null:
		return
	if body.is_in_group("player"):
		player = body
		detected = true

func _on_detection_body_exited(body: Node) -> void:
	if body == null:
		return
	if body.is_in_group("player") and not stick_on_detection:
		detected = false


# DAÑO RECIBIDO
func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount

	if hurt_sound.stream != null:
		hurt_sound.play()

	# Efecto visual de daño
	animated_sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)

	if health <= 0:
		die()


# DAÑO EN ÁREA (explosión al morir)
func explode_damage() -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new()
	query.shape.radius = explosion_radius
	query.transform = Transform2D(0, global_position)
	var results = space_state.intersect_shape(query)

	for res in results:
		var body = res.collider
		if body != null and body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(explosion_damage)

# MUERTE
func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	_can_shoot = false
	
	if death_sound.stream != null:
		AudioManager.play_sound(death_sound.stream, global_position, 3)
		
	var death_anim = "death_" + last_direction
	if animated_sprite.sprite_frames.has_animation(death_anim):
		animated_sprite.play(death_anim)
	else:
		animated_sprite.play("death_down")

	$AnimationPlayer.play("death_explode")
	animated_sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"), CONNECT_ONE_SHOT)


func _on_death_animation_finished() -> void:
	maybe_drop_heart()   # Función heredada de EnemyBase
	queue_free()
