# Este singleton se creó para manejar de forma eficiente los sonidos del juego.
# En lugar de crear y destruir un AudioStreamPlayer2D cada vez que se reproduce un sonido
# usamos un pool de nodos reutilizables. Cada sonido toma un nodo libre del pool y, al terminar, se
# devuelve para ser reutilizado. Esto mantiene el rendimiento y evita saturación de audio.

extends Node

@export var max_sounds: int = 10 # Número máximo de sonidos que pueden reproducirse simultáneamente.
var audio_pool: Array[AudioStreamPlayer2D] = [] # Pool de reproductores disponibles para reproducir nuevos sonidos.
var active_players: Array[AudioStreamPlayer2D] = [] # Lista de reproductores que actualmente están en uso.


# ----- Inicialización del sistema de audio ------

func _ready():
	# Crea una cantidad de nodos AudioStreamPlayer2D igual a 'max_sounds' 
	# y los añade al pool para su reutilización.
	for i in range(max_sounds):
		var player = AudioStreamPlayer2D.new()
		player.autoplay = false
		player.bus = "Master"
		
		# Conecta la señal 'finished' para detectar cuándo termina un sonido
		# y devolver el nodo al pool.
		player.connect("finished", Callable(self, "_on_player_finished").bind(player))
		
		audio_pool.append(player)
		get_tree().current_scene.add_child(player)


# ----------- Reproducción de sonidos ----------

func play_sound(audio_stream: AudioStream, position: Vector2, volume_db: float = 0.0):
	
	#Reproduce un sonido en la posición indicada usando un nodo del pool.
	#Si no hay nodos disponibles, el sonido se descarta para evitar saturación.
	
	if audio_stream == null:
		return
	
	# Si no hay reproductores disponibles, no se reproduce el sonido.
	if audio_pool.is_empty():
		return
	
	# Toma un reproductor libre del pool.
	var player = audio_pool.pop_back()
	active_players.append(player)
	
	# Configura las propiedades del reproductor antes de reproducir el sonido.
	player.stream = audio_stream
	player.global_position = position
	player.volume_db = volume_db
	
	# Inicia la reproducción.
	player.play()

# --------- Callback: cuando un sonido termina -----------

func _on_player_finished(player: AudioStreamPlayer2D):
	
	#Cuando un sonido finaliza, se elimina el reproductor de la lista de activos 
	#y se devuelve al pool para su reutilización.

	if active_players.has(player):
		active_players.erase(player)
	audio_pool.append(player)
