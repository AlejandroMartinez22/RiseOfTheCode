extends Node2D

@onready var current_room: Node2D = $CurrentRoom
@onready var player: Node2D = $Max

func _ready() -> void:
	# Registrar main en RoomManager
	RoomManager.register_main(self)

	# Asegurar que el player esté en el grupo "player"
	if not player.is_in_group("player"):
		player.add_to_group("player")

	# Conectar el HeartContainer del HUD a UIManager
	UIManager.heart_container = $CanvasLayer/MarginContainer/HeartContainer

	# Sincronizar datos entre Player y PlayerData (preservar estado entre salas)
	PlayerData.max_health = player.max_health
	# Si PlayerData.current_health ya estaba con un valor persistente, lo usamos;
	# si no, dejamos el valor del Player (esto permite continuar entre salas)
	player.current_health = PlayerData.current_health

	# Actualizar UI con el valor actual
	UIManager.update_hearts()

	# Cargar la sala inicial
	RoomManager.load_room("res://scenes/map/level1/recepcion.tscn")
