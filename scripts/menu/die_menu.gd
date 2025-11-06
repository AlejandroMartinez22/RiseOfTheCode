# Script del menú de muerte
# Ya no necesita gestionar la lógica de pausa, solo la UI
extends CanvasLayer

func _ready() -> void:
	# Asegurar que esté oculto al inicio
	hide()
	
	# Configurar para que funcione aunque el juego esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

# Nota: GameManager.player_died() se llama desde max.gd
# Este script solo maneja la visualización del menú

func _on_boton_menu_principal_pressed() -> void:
	$AudioStreamPlayer.stop()
	$BotonMenuPrincipal.get_node("AudioStreamPlayer").stop()
	
func _on_boton_reintentar_pressed() -> void:
	$AudioStreamPlayer.stop()
	$BotonMenuPrincipal.get_node("AudioStreamPlayer").stop()
