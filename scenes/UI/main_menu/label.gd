extends Label

@export var float_amount := 3.0    # Reducido de 10 a 3 (movimiento más sutil)
@export var float_speed := 1.5     # Más lento
@export var glow_speed := 2.0

var initial_position: Vector2
var time := 0.0

func _ready():
	initial_position = position
	
	# Animación de entrada
	modulate.a = 0.0
	scale = Vector2(0.5, 0.5)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _process(delta):
	time += delta
	
	# Efecto de flotación suave
	position.y = initial_position.y + sin(time * float_speed) * float_amount
	
	# Efecto de brillo pulsante
	var glow = (sin(time * glow_speed) + 1.0) / 2.0
	modulate = Color(1.0, 1.0, 1.0, 0.9 + glow * 0.1)
