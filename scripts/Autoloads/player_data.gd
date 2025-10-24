# Singleton que almacena la información persistente del jugador
# Ahora integrado con GameState para mayor coherencia
extends Node

var max_health: int = 30
var current_health: int = 30
var current_weapon: String = ""

# Restaura los valores del jugador a sus valores iniciales
# También resetea el estado completo del juego
func reset() -> void:
	max_health = 30
	current_health = max_health
	current_weapon = ""
	
	# IMPORTANTE: Resetear también GameState
	GameState.reset()
	
	print("PlayerData reseteado")
