extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite #Referencia al animatedSprite.
@export var projectile_scene: PackedScene   # aquí asignaremos red_bullet.tscn desde el editor

#Variables
var speed = 100 #Definimos una variable para la velocidad del movimiento. 400px en este caso
# Variable para la ultima direccion presionada
var last_direction = "down"
var has_weapon = false

func _physics_process(delta):
	get_input()
	move_and_slide() #Hace el movimiento del cuerpo basado en el valor de la propiedad Velocity
	# Si tiene arma y presiona K → dispara
	if has_weapon and Input.is_action_just_pressed("shoot"):
		shoot()
	
#Metodo que detecta lo que el usuario presiona	
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down") # Este metodo espera como parametros las 4 direcciones (left, right, top, down)
	
	if  input_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		update_animation("idle")
		return
	
	if abs(input_direction.x) > abs(input_direction.y): #Movimiento horizontal
		if (input_direction.x) > 0:
			last_direction = "right"
		else:
			last_direction = "left"
	else:
		if (input_direction.y) > 0:
			last_direction = "down"
		else:
			last_direction = "up"
			
				
	update_animation("walk")
	velocity = input_direction * speed #Esta es una propiedad del characterBody2D.
	
	
#metodo para actualizar las animaciones	
func update_animation(state):
	animated_sprite.play(state + "_" + last_direction)
	
# función para equipar arma 
func equip_weapon():
	has_weapon = true
	
# Disparo del proyectil 
func shoot():
	var bullet = projectile_scene.instantiate()
	bullet.global_position = global_position  # aparece desde el jugador
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
