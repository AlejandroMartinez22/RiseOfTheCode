#Este script actúa como el punto de entrada principal del juego.
# Se encarga de:
#   - Registrar la escena principal en el RoomManager.
#   - Asegurar que el jugador esté correctamente configurado.
#   - Conectar el HUD (interfaz de corazones) con el UIManager.
#   - Sincronizar los datos persistentes del jugador (PlayerData).
#   - Cargar la primera sala del juego.

extends Node2D

#Referencias a nodos hijos dentro de la escena principal
@onready var current_room: Node2D = $CurrentRoom    # Nodo contenedor donde se instancian las salas
@onready var player: Node2D = $Max              # Nodo del jugador principal

func _ready() -> void:
	randomize()  # Inicializa la semilla aleatoria (necesario para drops o comportamiento aleatorio)
	
	# Registro de la escena principal en el RoomManager
	# Esto permite que RoomManager tenga acceso al nodo 'main' para
	# cargar y reemplazar salas dentro de CurrentRoom.
	RoomManager.register_main(self)

	#Asegurar que el jugador pertenezca al grupo "player"
	if not player.is_in_group("player"):
		player.add_to_group("player")

	#Conectar el contenedor de corazones con el UIManager
	# UIManager necesita una referencia al nodo del HUD para poder
	# actualizar los corazones cuando cambia la vida del jugador.
	UIManager.heart_container = $CanvasLayer/MarginContainer/HeartContainer


	# 4️Sincronizar datos del jugador con PlayerData
	PlayerData.max_health = player.max_health

	# Si PlayerData ya tenía un valor previo (por ejemplo, tras cambiar de sala),
	# lo aplicamos al jugador; de lo contrario, usamos su valor inicial.
	player.current_health = PlayerData.current_health
	
	#Refrescar la UI con el valor actual de vida-
	UIManager.update_hearts()

	# Cargar la sala inicial del juego
	# Esto usa RoomManager para instanciar la primera sala dentro
	# del nodo CurrentRoom y posicionar al jugador en el spawn correcto.
	RoomManager.load_room("res://scenes/map/level1/recepcion.tscn")
