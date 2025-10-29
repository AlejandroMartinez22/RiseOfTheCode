extends CharacterBody2D
# Script que controla el comportamiento principal del jugador "Max"
# Ahora integrado con GameState para persistencia de armas

# MARKERS (puntos desde donde se disparan los proyectiles)
@onready var muzzle_down: Marker2D = $MuzzleDown
@onready var muzzle_right: Marker2D = $MuzzleRight
@onready var muzzle_left: Marker2D = $MuzzleLeft
@onready var muzzle_up: Marker2D = $MuzzleUp

# COMPONENTES (nodos hijos importantes del jugador)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

# REFERENCIAS EXTERNAS
var heart_container: Node = null
var current_weapon: Weapon = null

# VARIABLES DE MOVIMIENTO Y ESTADO
var speed: float = 100.0
var last_direction: String = "down"
var is_shooting: bool = false
var is_dead: bool = false

# SISTEMA DE VIDA (sincronizado con PlayerData)
var max_health: int = 30
var current_health: int = 30

func _ready() -> void:
	# Conectar evento de animación terminada
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

	# Buscar referencia a la UI en el nodo principal
	var main = get_tree().root.get_node("main")
	if main:
		heart_container = main.get_node("CanvasLayer/MarginContainer/HeartContainer")

	# Sincronizar datos locales con PlayerData (singleton global)
	max_health = PlayerData.max_health
	current_health = PlayerData.current_health

	# Actualizar la interfaz de vida al iniciar
	UIManager.update_hearts()

func _physics_process(delta: float) -> void:
	# Si el jugador está disparando, no puede moverse
	if is_shooting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	get_input()
	move_and_slide()

	# Control del disparo
	if current_weapon != null and Input.is_action_just_pressed("shoot"):
		var anim_name = current_weapon.shoot_anim_prefix + "_" + last_direction
		animated_sprite.play(anim_name)
		animated_sprite.speed_scale = current_weapon.shoot_speed_scale
		is_shooting = true
		velocity = Vector2.ZERO
		shoot()

func get_input() -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")

	if input_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		update_animation("idle")
		return

	# Determinar la dirección principal (horizontal o vertical)
	if abs(input_direction.x) > abs(input_direction.y):
		last_direction = "right" if input_direction.x > 0 else "left"
	else:
		last_direction = "down" if input_direction.y > 0 else "up"

	update_animation("walk")
	velocity = input_direction * speed

func update_animation(state: String) -> void:
	# Evita reproducir otras animaciones durante el disparo
	if not is_shooting:
		animated_sprite.play(state + "_" + last_direction)

# ==================== ARMAS Y DISPAROS ====================

func equip_weapon(new_weapon: Weapon) -> void:
	current_weapon = new_weapon
	
	# Actualizar en PlayerData
	PlayerData.current_weapon = new_weapon.name
	
	# Actualizar flag en GameState
	GameState.set_flag("has_weapon", true)
	
	print("✓ Jugador ahora tiene:", current_weapon.name)

func shoot() -> void:
	if current_weapon == null:
		return

	# Instanciar el proyectil del arma actual
	var bullet = current_weapon.projectile_scene.instantiate()

	# Posicionar y orientar el proyectil según la dirección
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

	bullet.target_group = "enemies"
	get_parent().add_child(bullet)

	# Reproducir sonido de disparo
	if current_weapon.shoot_sound != null:
		audio_player.stream = current_weapon.shoot_sound
		audio_player.play()

func _on_animation_finished() -> void:
	# Cuando termina la animación de disparo, se vuelve a estado idle
	if current_weapon == null:
		return
	if animated_sprite.animation.begins_with(current_weapon.shoot_anim_prefix):
		is_shooting = false
		update_animation("idle")

# ==================== VIDA Y DAÑO ====================

func take_damage(amount: int, source_position: Vector2 = global_position) -> void:
	if is_dead:
		return
		 
	# Reducir vida global y sincronizar con el nodo
	PlayerData.current_health = max(PlayerData.current_health - amount, 0)
	current_health = PlayerData.current_health

	UIManager.update_hearts()

	# Efectos de daño
	if hurt_sound.stream != null:
		hurt_sound.play()

	# Parpadeo rojo
	animated_sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)

	# Si la vida llega a cero, muere
	if PlayerData.current_health <= 0:
		die()

func heal(amount: int) -> void:
	# Curar al jugador
	PlayerData.current_health = min(PlayerData.current_health + amount, PlayerData.max_health)
	current_health = PlayerData.current_health
	UIManager.update_hearts()
	print("✓ Curado: +", amount, " HP")

func die() -> void:
	is_dead = true
	print("Jugador ha muerto")

	if death_sound.stream != null:
		death_sound.play()

	var death_anim = "death_" + last_direction
	animated_sprite.play(death_anim)

	velocity = Vector2.ZERO
	is_shooting = true

	# Conectamos una función para eliminar el nodo cuando acabe la animación
	animated_sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"))
	
	

func _on_death_animation_finished():
	queue_free()
	get_node("../DieMenu").game_over()
