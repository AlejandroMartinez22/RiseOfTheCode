# Script principal del juego
# Se encarga de inicializar todos los sistemas y registrar los menús
extends Node2D

# Referencias a nodos hijos
@onready var current_room: Node2D = $CurrentRoom
@onready var player: CharacterBody2D = $Max
@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var die_menu: CanvasLayer = $DieMenu

func _ready() -> void:
	randomize()
	
	# Registrar la escena principal en RoomManager
	RoomManager.register_main(self)
	
	# Asegurar que el jugador pertenezca al grupo "player"
	if not player.is_in_group("player"):
		player.add_to_group("player")
	
	# Conectar el contenedor de corazones con UIManager
	UIManager.heart_container = $CanvasLayer/MarginContainer/HeartContainer
	
	# Sincronizar datos del jugador con PlayerData
	PlayerData.max_health = player.max_health
	player.current_health = PlayerData.current_health
	
	# Refrescar la UI con el valor actual de vida
	UIManager.update_hearts()
	
	# Registrar los menús en GameManager
	GameManager.register_menus(pause_menu, die_menu)
	
	# Cargar la sala inicial del juego
	RoomManager.load_room("res://scenes/map/level1/recepcion.tscn")
	
	print("✅ Main inicializado correctamente")

func _input(event: InputEvent) -> void:
	# Detectar tecla ESC para pausar/reanudar
	if event.is_action_pressed("pausa"):
		GameManager.toggle_pause()
