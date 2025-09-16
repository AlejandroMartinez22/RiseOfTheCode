extends CharacterBody2D

var direction: float = 0.0 #direccion del proyectil
var speed: float = 1000.0 #velocidad del proyectil

func _ready():
	rotation = direction

func _physics_process(delta):
	velocity = Vector2(speed,0).rotated(direction) #La bala se mueve en la dirección correspondiente.
	move_and_slide()
	
	
