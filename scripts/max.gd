extends CharacterBody2D

# Markers para definir de donde sale el proyectil al disparar.
@onready var muzzle_down: Marker2D = $MuzzleDown
@onready var muzzle_right: Marker2D = $MuzzleRight
@onready var muzzle_left: Marker2D = $MuzzleLeft
@onready var muzzle_up: Marker2D = $MuzzleUp

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

# Referencia a la UI persistente (barra de vida en main)
var heart_container: Node = null

var speed: float = 100.0
var last_direction: String = "down"
var is_shooting: bool = false

# Mantengo variables locales solo para uso interno/visual; siempre las sincronizo con PlayerData
var max_health: int = 30
var current_health: int = 30

var current_weapon: Weapon = null

func _ready() -> void:
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

	var main = get_tree().root.get_node("main")
	if main:
		heart_container = main.get_node("CanvasLayer/MarginContainer/HeartContainer")

	# --- sincronizar con PlayerData (PlayerData es la fuente de verdad) ---
	max_health = PlayerData.max_health
	current_health = PlayerData.current_health
	# Aseguramos que la UI muestre el valor real al inicio
	UIManager.update_hearts()


func _physics_process(delta: float) -> void:
	if is_shooting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	get_input()
	move_and_slide()

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

	if abs(input_direction.x) > abs(input_direction.y):
		last_direction = "right" if input_direction.x > 0 else "left"
	else:
		last_direction = "down" if input_direction.y > 0 else "up"

	update_animation("walk")
	velocity = input_direction * speed


func update_animation(state: String) -> void:
	if not is_shooting:
		animated_sprite.play(state + "_" + last_direction)


func equip_weapon(new_weapon: Weapon) -> void:
	current_weapon = new_weapon
	print("Jugador ahora tiene:", current_weapon.name)


func shoot() -> void:
	if current_weapon == null:
		return

	var bullet = current_weapon.projectile_scene.instantiate()

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

	if current_weapon.shoot_sound != null:
		audio_player.stream = current_weapon.shoot_sound
		audio_player.play()


func _on_animation_finished() -> void:
	if current_weapon == null:
		return
	if animated_sprite.animation.begins_with(current_weapon.shoot_anim_prefix):
		is_shooting = false
		update_animation("idle")


# ----------------- VIDA (ahora usando PlayerData como fuente de verdad) -----------------
func take_damage(amount: int, source_position: Vector2 = global_position) -> void:
	# Reducimos la vida en el singleton
	PlayerData.current_health = max(PlayerData.current_health - amount, 0)
	# sincronizamos la variable local para que el nodo jugador refleje el valor
	current_health = PlayerData.current_health

	print("Jugador recibió daño: ", amount, " Vida restante: ", PlayerData.current_health)

	# Actualizar UI (UIManager lee PlayerData.current_health)
	UIManager.update_hearts()

	# sonido de daño
	if hurt_sound.stream != null:
		hurt_sound.play()

	# flash rojo
	animated_sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)

	# muerte
	if PlayerData.current_health <= 0:
		die()


func die() -> void:
	print("Jugador ha muerto")

	if death_sound.stream != null:
		death_sound.play()

	var death_anim = "death_" + last_direction
	animated_sprite.play(death_anim)

	velocity = Vector2.ZERO
	is_shooting = true

	animated_sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"))


func _on_death_animation_finished():
	queue_free()
