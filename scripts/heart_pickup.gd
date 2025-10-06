extends PickupItem

# Este código suma vida al jugador sin pasar del máximo.
# Llama al UIManager para refrescar la barra de corazones.
# No hace nada extra si ya está a tope de vida.

@export var heal_amount: int = 10
@export var lifetime: float = 15.0       # Tiempo total antes de desaparecer
@export var blink_duration: float = 3.0   # Parpadea los últimos 2 segundos
@export var blink_interval: float = 0.2   # Cada cuánto parpadea

var blink_timer: Timer
var is_blinking: bool = false

func _ready() -> void:
	# Iniciamos el temporizador de autodestrucción
	start_lifetime_timer()

func start_lifetime_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = lifetime - blink_duration
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_blink_start)
	timer.start()

func _on_blink_start() -> void:
	print("[HeartPickup] Iniciando parpadeo antes de desaparecer")

	# Crear un segundo timer que controla los parpadeos
	blink_timer = Timer.new()
	blink_timer.wait_time = blink_interval
	blink_timer.one_shot = false
	add_child(blink_timer)
	blink_timer.timeout.connect(_on_blink)
	blink_timer.start()

	# Y un tercer timer que elimina el corazón después del parpadeo
	var end_timer := Timer.new()
	end_timer.wait_time = blink_duration
	end_timer.one_shot = true
	add_child(end_timer)
	end_timer.timeout.connect(_on_lifetime_timeout)
	end_timer.start()

	is_blinking = true

func _on_blink() -> void:
	if not is_blinking:
		return
	# Alternamos la visibilidad para simular parpadeo
	visible = not visible

func _on_lifetime_timeout() -> void:
	print("[HeartPickup] Expiró tras", lifetime, "segundos:", name)
	is_blinking = false
	visible = true  # nos aseguramos de que quede visible justo antes de desaparecer
	queue_free()

func on_picked_up(body: Node2D) -> void:
	print("[HeartPickup] recogido por:", body.name, " PlayerData:", PlayerData.current_health, "/", PlayerData.max_health)
	
	if PlayerData.current_health >= PlayerData.max_health:
		print("[HeartPickup] Jugador ya está con vida completa")
		return
	
	PlayerData.current_health = min(PlayerData.current_health + heal_amount, PlayerData.max_health)
	print("[HeartPickup] Jugador curado. Vida actual:", PlayerData.current_health)

	UIManager.update_hearts()
	queue_free()  # Asegura eliminar el corazón al recogerlo
