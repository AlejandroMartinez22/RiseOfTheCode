# Este script controla una "zona de salida" del nivel.
# Cuando el jugador entra en esta área, se carga otra sala
# definida en la variable next_room_path, y el jugador
# aparece en el punto spawn_name dentro de la nueva escena.

extends Area2D

# Ruta de la escena que se cargará al entrar en esta salida
@export var next_room_path: String = "res://tilemap/Niveles/Nivel1/Biblioteca.tscn"

# Nombre del nodo "SpawnPoint" dentro de la nueva escena
@export var spawn_name: String = "SpawnPoint"

func _ready() -> void:
	# Conecta la señal "body_entered" si aún no está conectada.
	# Esto asegura que el código funcione incluso si la conexión no se hizo en el editor.
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

# Se llama cuando un cuerpo entra en el área de salida
func _on_body_entered(body: Node) -> void:
	# Solo responde al jugador (evita activar por enemigos o balas)
	if body.is_in_group("player"):
		# Carga la nueva sala a través del RoomManager
		RoomManager.load_room(next_room_path, spawn_name)
