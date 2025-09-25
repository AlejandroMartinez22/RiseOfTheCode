extends Node
# Este singleton se creó para manejar de forma eficiente los sonidos del juego,
# especialmente los disparos y las muertes de enemigos. En lugar de crear y destruir
# un AudioStreamPlayer2D cada vez que se reproduce un sonido (lo que puede saturar
# el juego si hay muchos enemigos disparando al mismo tiempo), usamos un pool de
# nodos reutilizables. Cada sonido toma un nodo libre del pool y, al terminar, se
# devuelve para ser reutilizado. Esto mantiene el rendimiento, evita saturación de audio,
# y permite controlar la mezcla y posición 2D de los sonidos de manera centralizada.

@export var max_sounds: int = 10

var audio_pool: Array[AudioStreamPlayer2D] = []
var active_players: Array[AudioStreamPlayer2D] = []

func _ready():
	# Crear AudioStreamPlayer2D al inicio y añadirlos al pool
	for i in range(max_sounds):
		var player = AudioStreamPlayer2D.new()
		player.autoplay = false
		player.bus = "Master"  # Ajusta si quieres otro bus
		player.connect("finished", Callable(self, "_on_player_finished").bind(player))
		audio_pool.append(player)
		get_tree().current_scene.add_child(player)

# ------------------- Función para reproducir sonidos -------------------
func play_sound(audio_stream: AudioStream, position: Vector2, volume_db: float = 0.0):
	"""
	Reproduce un sonido en la posición indicada usando un nodo del pool.
	Si no hay nodos libres, el sonido se descarta para evitar saturación.
	"""
	if audio_stream == null:
		return
	
	# Revisar si hay nodos libres
	if audio_pool.is_empty():
		return
	
	var player = audio_pool.pop_back()
	active_players.append(player)
	
	player.stream = audio_stream
	player.global_position = position
	player.volume_db = volume_db
	player.play()

# ------------------- Callback cuando un sonido termina -------------------
func _on_player_finished(player: AudioStreamPlayer2D):
	"""
	Cuando el sonido termina, se devuelve el nodo al pool para reutilización
	"""
	if active_players.has(player):
		active_players.erase(player)
	audio_pool.append(player)
