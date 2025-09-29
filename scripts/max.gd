extends CharacterBody2D

# Markers para definir de donde sale el proyectil al disparar.
@onready var muzzle_down: Marker2D = $MuzzleDown
@onready var muzzle_right: Marker2D = $MuzzleRight
@onready var muzzle_left: Marker2D = $MuzzleLeft
@onready var muzzle_up: Marker2D = $MuzzleUp

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D   # sonidos de disparo
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound           # sonido de recoger armas
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound #Sonido cuando recibe daño
@onready var death_sound: AudioStreamPlayer2D = $DeathSound #Sonido cuando muere

#Variable relacionada a la barra de vida
@onready var heart_container = get_tree().root.get_node("main/CanvasLayer/MarginContainer/HeartContainer")


var speed: float = 100.0 #Velocidad a la que se mueve
var last_direction: String = "down" #Ultima dirección.
var is_shooting: bool = false #Bandera para saber si está o no disparando.
var max_health: int = 30 #Vida máxima de Max
var current_health: int = 30 #Vida actual de Max (cambia cuando le hacen daño)

var current_weapon: Weapon = null   # aquí guardamos el arma equipada

func _ready() -> void:
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	if is_shooting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	get_input()
	move_and_slide()

	# 🔫 disparo
	if current_weapon != null and Input.is_action_just_pressed("shoot"):
		var anim_name = current_weapon.shoot_anim_prefix + "_" + last_direction
		animated_sprite.play(anim_name)
		animated_sprite.speed_scale = current_weapon.shoot_speed_scale

		is_shooting = true
		velocity = Vector2.ZERO
		shoot()

# ----------------- Input -----------------
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

# ----------------- Animaciones -----------------
func update_animation(state: String) -> void:
	if not is_shooting:
		animated_sprite.play(state + "_" + last_direction)

# ----------------- Arma y disparo -----------------
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

	bullet.target_group = "enemies" #Esta bala dañará a enemigos.
	get_parent().add_child(bullet)

	# 🎵 reproducir sonido del arma
	if current_weapon.shoot_sound != null:
		audio_player.stream = current_weapon.shoot_sound
		audio_player.play()

# ----------------- Sonido de recoger armas -----------------
func play_pickup_sound() -> void:
	if pickup_sound.stream != null:
		pickup_sound.play()

# ----------------- Callback -----------------
func _on_animation_finished() -> void:
	if current_weapon == null:
		return
		
	if animated_sprite.animation.begins_with(current_weapon.shoot_anim_prefix):
		is_shooting = false
		update_animation("idle")
		
# ----------------- funcion para recibir daño -----------------
func take_damage(amount: int, source_position: Vector2 = global_position) -> void:
	current_health -= amount
	print("Jugador recibió daño: ", amount, " Vida restante: ", current_health)
	
	# Actualizar UI
	heart_container.update_hearts(current_health) # 👈 ajustamos porque tu vida está en 3000
	
	# Reproducir sonido de daño
	if hurt_sound.stream != null:
		hurt_sound.play()
		
	# Efecto visual (flash rojo)
	animated_sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)
	
	# Si la vida llega a 0
	if current_health <= 0: 
		die()
		
	
		
# ----------------- funcion de muerte -----------------		
func die() -> void:
	print("Jugador ha muerto")
	
	# Reproducir sonido de muerte
	if death_sound.stream != null:
		death_sound.play()
	
	# Reproducir animación según la última dirección
	var death_anim = "death_" + last_direction
	animated_sprite.play(death_anim)
	
	# Detener movimiento y disparo
	velocity = Vector2.ZERO
	is_shooting = true
	
	# Esperar a que termine la animación para eliminar el nodo
	animated_sprite.connect("animation_finished", Callable(self, "_on_death_animation_finished"))

# ----------------- funcion fin de muerte  -----------------		
func _on_death_animation_finished():
	queue_free()  # Elimina el nodo del jugador una vez ya terminó de reproducirse su animación de muerte.
