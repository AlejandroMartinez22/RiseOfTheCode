
# Script para el corazón que puede recoger el jugador.
# Hereda de PickupItem, por lo que ya maneja detección y sonido.

# Funcionalidad:
# - Aumenta la vida del jugador sin pasar del máximo.
# - Actualiza el HUD de corazones (UIManager).
# - Desaparece tras cierto tiempo, parpadeando antes de hacerlo.

extends PickupItem

@export var heal_amount: int = 10         # Cantidad de vida que recupera el jugador
@export var lifetime: float = 12.0        # Tiempo total antes de desaparecer
@export var blink_duration: float = 2.0   # Tiempo final durante el cual parpadea
@export var blink_interval: float = 0.2   # Frecuencia del parpadeo

var blink_timer: Timer
var is_blinking: bool = false

func _ready() -> void:
	# Iniciamos el temporizador de vida útil al aparecer
	start_lifetime_timer()

# Crea un temporizador que controla la desaparición del ítem
func start_lifetime_timer() -> void:
	
	# Evitar valores mal configurados en el editor
	if blink_duration >= lifetime:
		push_warning("HeartPickup: blink_duration >= lifetime. Ajustando automáticamente.")
		blink_duration = max(0.5, lifetime / 3.0)

	var timer := Timer.new()
	timer.wait_time = lifetime - blink_duration
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_blink_start)
	timer.start()


# Inicia el parpadeo cuando está por expirar
func _on_blink_start() -> void:
	print("[HeartPickup] Iniciando parpadeo antes de desaparecer")

	# Timer para alternar visibilidad
	blink_timer = Timer.new()
	blink_timer.wait_time = blink_interval
	blink_timer.one_shot = false
	add_child(blink_timer)
	blink_timer.timeout.connect(_on_blink)
	blink_timer.start()

	# Timer final que elimina el ítem tras parpadear
	var end_timer := Timer.new()
	end_timer.wait_time = blink_duration
	end_timer.one_shot = true
	add_child(end_timer)
	end_timer.timeout.connect(_on_lifetime_timeout)
	end_timer.start()

	is_blinking = true


# Alterna visibilidad para simular parpadeo
func _on_blink() -> void:
	if is_blinking:
		visible = not visible

# Se ejecuta cuando expira completamente el tiempo de vida
func _on_lifetime_timeout() -> void:
	print("[HeartPickup] Expiró tras", lifetime, "segundos:", name)
	is_blinking = false
	visible = true  # asegúrate de que no desaparezca "invisible"
	queue_free()

# Acción cuando el jugador recoge el corazón
func on_picked_up(body: Node2D) -> void:
	print("[HeartPickup] Recogido por:", body.name, "| Vida:", PlayerData.current_health, "/", PlayerData.max_health)
	
	# No hace nada si ya tiene vida completa
	if PlayerData.current_health >= PlayerData.max_health:
		print("[HeartPickup] Jugador ya está con vida completa")
		return
	
	# Cura al jugador y actualiza UI
	PlayerData.current_health = min(PlayerData.current_health + heal_amount, PlayerData.max_health)
	print("[HeartPickup] Jugador curado. Vida actual:", PlayerData.current_health)

	UIManager.update_hearts()

	# Detiene el parpadeo (si estaba activo) antes de eliminar el nodo
	is_blinking = false
	visible = true
	queue_free()
