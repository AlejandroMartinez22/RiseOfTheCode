# victory_menu.gd
# Menú que se muestra cuando el jugador gana el juego
extends CanvasLayer

func _ready() -> void:
	# Asegurar que esté oculto al inicio
	hide()
	
	# Configurar para que funcione aunque el juego esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("✅ VictoryMenu inicializado")

# Nota: El botón "Volver al menú" usa main_menu_button.gd
# que ya tiene la lógica para regresar al menú principal
