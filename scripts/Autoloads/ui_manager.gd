# Singleton encargado de gestionar los elementos de la interfaz de usuario.
# Actúa como un puente entre la lógica del juego y los nodos de la interfaz.
# Por ejemplo, cuando cambia la vida del jugador, este script actualiza
# el contenedor de corazones usando los valores del PlayerData.

extends Node 

var heart_container: Node = null  # Referencia al nodo que contiene los corazones de vida en la interfaz.

# ------ Función: update_hearts --------

# Actualiza la visualización de los corazones en la interfaz de usuario.
# Lee el valor actual de vida desde PlayerData y lo envía al nodo heart_container.
func update_hearts() -> void:
	if heart_container != null:
		# El contenedor se encarga de redibujar los corazones según la vida actual.
		heart_container.update_hearts(PlayerData.current_health)
