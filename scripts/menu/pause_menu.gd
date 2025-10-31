# Script del menú de pausa
# Ya no necesita gestionar la lógica de pausa, solo la UI
extends CanvasLayer

func _ready() -> void:
	# Asegurar que esté oculto al inicio
	hide()
	
	# Configurar para que funcione aunque el juego esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

# Nota: La detección de ESC ahora está en main.gd
# Este script solo maneja la visualización del menú
