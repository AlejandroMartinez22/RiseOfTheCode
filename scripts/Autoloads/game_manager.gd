# Singleton que gestiona el flujo completo del juego
# Controla: inicio, pausa, muerte, reinicio y navegación entre menús
extends Node

# Referencias a los menús (se configuran desde main.tscn)
var pause_menu: CanvasLayer = null
var die_menu: CanvasLayer = null

# Estado del juego
var is_game_paused: bool = false
var player_is_dead: bool = false

# Rutas de escenas CAMBIAR LAS RUTAS
const MAIN_MENU_PATH = "res://scenes/menu/main_menu.tscn"
const MAIN_GAME_PATH = "res://scenes/main.tscn"
const FIRST_ROOM_PATH = "res://scenes/map/level1/recepcion.tscn"

# ==================== INICIAR JUEGO ====================

# Inicia una nueva partida desde el menú principal
func start_new_game() -> void:
	print("🎮 Iniciando nueva partida...")
	
	# Resetear todo el estado del juego
	reset_game_state()
	
	# Cargar la escena principal del juego
	get_tree().change_scene_to_file(MAIN_GAME_PATH)

# Resetea todos los datos del juego a sus valores iniciales
func reset_game_state() -> void:
	print("🔄 Reseteando estado del juego...")
	
	# Resetear singletons
	PlayerData.reset()  # Vida a 30, sin arma
	GameState.reset()   # Enemigos, items, puzzles, etc.
	
	# Resetear flags locales
	is_game_paused = false
	player_is_dead = false
	
	# Despausar por si acaso
	get_tree().paused = false

# ==================== SISTEMA DE PAUSA ====================

# Alterna entre pausar y reanudar el juego
func toggle_pause() -> void:
	if player_is_dead:
		return  # No permitir pausar si el jugador está muerto
	
	if is_game_paused:
		resume_game()
	else:
		pause_game()

# Pausa el juego y muestra el menú de pausa
func pause_game() -> void:
	if player_is_dead:
		return
	
	print("⏸️ Juego pausado")
	
	is_game_paused = true
	get_tree().paused = true
	
	if pause_menu:
		pause_menu.show()

# Reanuda el juego y oculta el menú de pausa
func resume_game() -> void:
	print("▶️ Juego reanudado")
	
	is_game_paused = false
	get_tree().paused = false
	
	if pause_menu:
		pause_menu.hide()

# ==================== SISTEMA DE MUERTE ====================

# Se llama cuando el jugador muere
func player_died() -> void:
	print("💀 Jugador murió")
	
	player_is_dead = true
	is_game_paused = true
	get_tree().paused = true
	
	if die_menu:
		die_menu.show()
		var audio_player = die_menu.get_node("AudioStreamPlayer")
		if audio_player:
			audio_player.play()

# ==================== REINICIAR JUEGO ====================

# Reinicia el juego desde el principio (tras morir o desde pausa)
func restart_game() -> void:
	print("🔄 Reiniciando juego...")
	
	# Resetear estado
	reset_game_state()
	
	# Ocultar menús
	if pause_menu:
		pause_menu.hide()
	if die_menu:
		die_menu.hide()
	
	# Recargar la escena principal
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_GAME_PATH)

# ==================== VOLVER AL MENÚ PRINCIPAL ====================

# Regresa al menú principal (desde pausa o muerte)
func return_to_main_menu() -> void:
	print("🏠 Regresando al menú principal...")
	
	# Resetear estado
	reset_game_state()
	
	# Ocultar menús
	if pause_menu:
		pause_menu.hide()
	if die_menu:
		die_menu.hide()
	
	# Cargar menú principal
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

# ==================== CONFIGURACIÓN ====================

# Registra los menús desde main.tscn
func register_menus(pause: CanvasLayer, die: CanvasLayer) -> void:
	pause_menu = pause
	die_menu = die
	
	# Asegurar que estén ocultos al inicio
	if pause_menu:
		pause_menu.hide()
		pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS  # Funciona aunque el juego esté pausado
	
	if die_menu:
		die_menu.hide()
		die_menu.process_mode = Node.PROCESS_MODE_ALWAYS  # Funciona aunque el juego esté pausado
	
	print("✅ Menús registrados en GameManager")

# ==================== SALIR DEL JUEGO ====================

# Cierra el juego completamente
func quit_game() -> void:
	print("👋 Saliendo del juego...")
	get_tree().quit()
