extends CharacterBody2D

@onready var muzzle: Marker2D = $Muzzle
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var detection_area: Area2D = $DetectionArea

@export var data: EnemyData                # Recurso con stats
@export var projectile_scene: PackedScene  # Escena del proyectil
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound

# Comportamiento de detección
@export var stick_on_detection: bool = true    # si true, una vez detectado no deja de perseguir aunque salga del area
@export var smoothing_factor: float = 0.0      # 0 = sin suavizado, 0.2 = suave. Ajusta a gusto.

#Explosion del centinela. Se le asigna un radio, y un daño.
@export var explosion_radius: float = 35.0 #Concuerda exactamente con el áre de explosión en el sprite de muerte.
@export var explosion_damage: int = 10


var player: Node = null
var health: int
var _can_shoot: bool = true
var last_direction: String = "down"
var is_dead: bool = false
var detected: bool = false

func _ready() -> void:
	health = data.max_health
	update_animation()

	# Buscar al jugador globalmente (por si ya está)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

	# Asegurar que el detection_area conecta sus señales
	if detection_area and not detection_area.is_connected("body_entered", Callable(self, "_on_detection_body_entered")):
		detection_area.connect("body_entered", Callable(self, "_on_detection_body_entered"))
	if detection_area and not detection_area.is_connected("body_exited", Callable(self, "_on_detection_body_exited")):
		detection_area.connect("body_exited", Callable(self, "_on_detection_body_exited"))

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Si no tenemos referencia al jugador, intentar obtenerla (por si se instancia después)
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	# Si no estamos detectados, mantén comportamiento idle/patrulla (aquí idle)
	if not detected or player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation()  # sigue mostrando idle
		return

	# Si llegamos aquí: player != null y detected == true -> perseguir / disparar
	var dir = global_position.direction_to(player.global_position)  # dirección normalizada hacia el jugador

	# aplicar suavizado si está activado
	var look_dir = (player.global_position - global_position).normalized()
	var final_dir = dir.lerp(look_dir, clamp(smoothing_factor, 0.0, 1.0)) if smoothing_factor > 0.0 else dir


	var dist = global_position.distance_to(player.global_position)
	if dist > data.attack_range:
		# mover hacia el jugador
		velocity = dir * data.speed
		move_and_slide()
		update_direction(final_dir)
		update_animation()  # play walk_*
	else:
		# dentro del rango de ataque -> parar y disparar
		velocity = Vector2.ZERO
		move_and_slide()
		update_direction(final_dir)  # importante: siempre mirar al jugador
		update_animation()            # play idle_* mientras dispara
		if _can_shoot and projectile_scene != null:
			shoot()

# ---------------- Animaciones ----------------
func update_animation() -> void:
	if is_dead:
		return
	# Siempre reproducir la animación idle según la última dirección
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

# ---------------- Disparo ----------------
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

# ---------------- Detección (Area2D signals) ----------------
func _on_detection_body_entered(body: Node) -> void:
	if body == null:
		return
	# Aceptamos si es el jugador (por grupo)
	if body.is_in_group("player"):
		player = body
		detected = true
		# opcional: reproducir un sonido de alerta
		# AudioManager.play_sound(alert_sound, global_position)

func _on_detection_body_exited(body: Node) -> void:
	if body == null:
		return
	if body.is_in_group("player"):
		# Si stick_on_detection == false, perdemos el target al salir. Si es true, no hacemos nada.
		if not stick_on_detection:
			detected = false
			# aquí también podrías reiniciar patrulla / estado

# ---------------- Daño ----------------
func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	if hurt_sound.stream != null:
		hurt_sound.play()
	animated_sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)
	if health <= 0:
		die()

# ---------- Funcion para hacer daño en área ----------
func explode_damage() -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new()
	query.shape.radius = explosion_radius
	query.transform = Transform2D(0, global_position)

	var results = space_state.intersect_shape(query)

	for res in results:
		var body = res.collider
		if body != null and body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(explosion_damage)

# ---------------- Muerte ----------------
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
		animated_sprite.play("death_down") #El animated sprite dibuja las imagenes del centinela "Muriendo"
	
	$AnimationPlayer.play("death_explode") #El animationplayer, controla propiedades de los nodos, para hacer que la onda expansiva de la explosión se vea más grande.
	animated_sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"), CONNECT_ONE_SHOT)

func _on_death_animation_finished() -> void:
	queue_free()
