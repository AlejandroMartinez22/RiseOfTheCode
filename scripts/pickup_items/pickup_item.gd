extends Area2D
class_name PickupItem

# Clase base para todos los objetos recogibles del juego (corazones, armas, etc.)
# Se encarga de detectar cuándo el jugador entra en su área de colisión y 
# ejecutar la lógica de recogida común: reproducir sonido y eliminarse del mundo.

# VARIABLES EXPORTADAS
@export var pickup_sound: AudioStream = null  # Sonido que se reproducirá al recoger el objeto


# CICLO DE VIDA
func _ready() -> void:
	# Activamos detección de colisiones
	monitoring = true
	monitorable = true
	
	# Conectamos la señal 'body_entered' si no lo está (evita duplicados)
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))


# MÉTODO VIRTUAL (sobrescribible por subclases)
func on_picked_up(_body: Node2D) -> void:
	#Este método se sobreescribirá en las clases hijas.
	pass

# DETECCIÓN DE COLISIÓN

func _on_body_entered(body: Node2D) -> void:
	# Solo reaccionar si el cuerpo pertenece al grupo "player"
	if not body.is_in_group("player"):
		return
	
	# Ejecutar la acción específica del objeto (definida en la subclase)	
	on_picked_up(body)
	
	# Reproducir sonido de recogida si está definido
	if pickup_sound:
		AudioManager.play_sound(pickup_sound, global_position)
	
	# Eliminar el objeto de la escena tras ser recogido
	queue_free()
