extends Area2D

@export var next_room_path: String = "res://tilemap/Niveles/Nivel1/Biblioteca.tscn"
@export var spawn_name: String = "SpawnPoint"

func _ready() -> void:
	# Conexión segura de la señal (opcional si ya la conectaste en el editor)
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		RoomManager.load_room(next_room_path, spawn_name)
