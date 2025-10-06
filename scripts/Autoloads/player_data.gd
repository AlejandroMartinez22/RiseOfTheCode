# Singleton (autoload) que almacena la información persistente del jugador.
# Sirve para mantener datos entre cambios de escena, como la vida o el arma equipada. 

extends Node

var max_health: int = 30 # Vida máxima del jugador.
var current_health: int = 30 # Vida actual.
var current_weapon: String = "" # Nombre del arma actual equipada por el jugador.

# Restaura los valores del jugador a sus valores iniciales. 
# Se utiliza, por ejemplo, al comenzar una nueva partida o tras un "game over".
func reset() -> void:
	max_health = 30
	current_health = max_health
	current_weapon = ""
