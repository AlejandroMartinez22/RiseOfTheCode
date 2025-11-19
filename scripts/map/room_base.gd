# room_base.gd
# Script base para todas las salas del juego
# Maneja el spawn de enemigos pendientes cuando se carga la sala
extends Node2D

func _ready() -> void:
	# Esperar a que la sala esté completamente inicializada
	await get_tree().process_frame
	
	# Verificar y spawnear enemigos pendientes
	check_pending_enemy_spawns()

func check_pending_enemy_spawns() -> void:
	var room_path = RoomManager.get_current_room_path()
	var pending = GameState.get_pending_spawns(room_path)
	
	if pending.is_empty():
		return
	
	print("🔫 Verificando enemigos pendientes en: ", room_path)
	
	for spawn_data in pending:
		var enemy_id: String = spawn_data.get("enemy_id")
		
		# Solo spawnear si NO ha sido eliminado
		if not GameState.is_enemy_killed(room_path, enemy_id):
			spawn_enemy(spawn_data)
		else:
			print("⚠️ Enemigo ya eliminado, no spawneando: ", enemy_id)

func spawn_enemy(data: Dictionary) -> void:
	var enemy_scene: PackedScene = data.get("scene")
	var pos: Vector2 = data.get("position")
	var enemy_id: String = data.get("enemy_id")
	
	# Instanciar enemigo
	var enemy = enemy_scene.instantiate()
	
	# Configurar ID
	if "enemy_id" in enemy:
		enemy.enemy_id = enemy_id
	
	# Posicionar
	enemy.global_position = pos
	
	# Agregar a la escena
	add_child(enemy)
	
	print("✓ Enemigo spawneado: ", enemy_id, " en ", pos)
