# Este script permite reutilizar la lógica de detección (cuando el jugador entra en el área)
# que tienen todos los objetos recogibles a lo largo del juego.

extends Area2D
class_name PickupItem

@export var pickup_sound: AudioStream = null

func _ready() -> void:
	# Aseguramos que el Area2D esté activa para detectar colisiones
	monitoring = true
	monitorable = true
	
	# Conexión automática de la señal body_entered, si aún no está conectada
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

# Este método se sobreescribirá en subclases (arma, corazón, etc.)
func on_picked_up(body: Node2D) -> void:
	pass

# Lógica común de interacción
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	# Acción específica (se define en las subclases)
	on_picked_up(body)
	
	# Sonido de recogida (si tiene)
	if pickup_sound:
		AudioManager.play_sound(pickup_sound, global_position)
	
	# Eliminamos el objeto del mundo
	queue_free()
