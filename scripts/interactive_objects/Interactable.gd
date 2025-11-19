# interactable.gd
# Sistema UNIFICADO de interacción para:
# 1. Objetos informativos (notas, tableros, computadores)
# 2. Items simples (llaves, ácido) - Solo añaden al inventario
# 3. Objetos híbridos (nota + item) - Muestran info Y dan item
extends Area2D

# ==================== CONFIGURACIÓN BÁSICA ====================
@export var interact_name: String = "presiona E para interactuar"
@export var is_interactable: bool = true
@export var item_id: String = ""  # ID único para persistencia (ej: "llave_director_recepcion")

# ==================== TIPO DE INTERACCIÓN ====================
enum InteractionMode {
	INFO_ONLY,      # Solo muestra información (nota/tablero/computador)
	ITEM_ONLY,      # Solo añade item al inventario (llave/ácido)
	INFO_THEN_ITEM  # Muestra info y luego da item (nota híbrida)
}

@export var interaction_mode: InteractionMode = InteractionMode.INFO_ONLY

# ==================== PARA INFO_ONLY E INFO_THEN_ITEM ====================
@export_group("Contenido Visual")
@export_enum("nota", "tablero", "computador") var content_type: String = "nota"
@export var content_pages: Array[Texture2D] = []

# ==================== PARA ITEM_ONLY E INFO_THEN_ITEM ====================
@export_group("Item a Obtener")
@export var item_key: String = ""     # Clave del item (ej: "llave_director")
@export var pickup_message: String = "" # Mensaje al obtener item (ej: "Con esto podré escapar")

# ==================== OCULTAR TILE DEL TILEMAP ====================
@export_group("Ocultar Visual del Tilemap")
@export var hide_tilemap_on_pickup: bool = false  # ¿Ocultar tile al recoger?
@export var hide_interactable_on_pickup: bool = true  # ¿Eliminar Area2D al recoger?
@export var tilemap_layer_name: String = "ObjectsLayer"  # Nombre de la capa del tilemap
@export var tile_coords: Vector2i = Vector2i(0, 0)  # Coordenadas del tile a ocultar

# ==================== SONIDO DE PICKUP ====================
@export_group("Audio")
@export var pickup_sound: AudioStream = null  # Sonido al recoger el item

# ==================== VARIABLES INTERNAS ====================
var was_collected: bool = false

# Callable que se ejecuta al interactuar
var interact: Callable = func():
	match interaction_mode:
		InteractionMode.INFO_ONLY:
			show_content_viewer()
		
		InteractionMode.ITEM_ONLY:
			# Solo dar item si no fue recogido
			if not was_collected:
				give_item_immediately()
		
		InteractionMode.INFO_THEN_ITEM:
			show_content_then_give_item()

func _ready() -> void:
	# Configurar capas de colisión
	collision_layer = 32  # Capa 6 (para que InteractingComponent lo detecte)
	collision_mask = 0
	
	# Auto-generar ID si no está configurado
	if item_id.is_empty():
		item_id = name + "_" + str(get_instance_id())
	
	# Verificar si este objeto ya fue recogido
	var room_path = RoomManager.get_current_room_path()
	if GameState.is_item_collected(room_path, item_id):
		was_collected = true
		
		# Solo eliminar si está configurado para ocultarse
		if hide_interactable_on_pickup:
			is_interactable = false
			
			# Ocultar tile si corresponde
			if hide_tilemap_on_pickup:
				hide_tilemap_tile()
			
			queue_free()  # Eliminarse si ya fue recogido
			return
		
		# Si NO se oculta, permitir releer pero sin dar item de nuevo
		# is_interactable permanece true
		print("✓ Objeto ya recogido pero se puede releer: ", name)

# ==================== MODO 1: INFO_ONLY ====================
func show_content_viewer() -> void:
	if content_pages.is_empty():
		push_error("❌ No hay texturas asignadas en content_pages para: " + name)
		return
	
	print("📖 Mostrando contenido: ", name)
	
	var ui_content_type: UIManager.ContentType
	match content_type:
		"nota":
			ui_content_type = UIManager.ContentType.NOTE
		"tablero":
			ui_content_type = UIManager.ContentType.BOARD
		"computador":
			ui_content_type = UIManager.ContentType.COMPUTER
		_:
			ui_content_type = UIManager.ContentType.NOTE
	
	UIManager.show_content(content_pages, ui_content_type)

# ==================== MODO 2: ITEM_ONLY ====================
func give_item_immediately() -> void:
	# NUEVO: Reproducir sonido ANTES de hacer nada
	if pickup_sound:
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = pickup_sound
		audio_player.volume_db = -5.0
		audio_player.bus = "Master"
		add_child(audio_player)
		audio_player.play()
		print("🔊 Reproduciendo sonido de pickup")
		
		# Esperar a que termine el sonido
		await audio_player.finished
		audio_player.queue_free()
	
	# Agregar item al inventario
	if not item_key.is_empty():
		GameState.add_item(item_key)
	
	# Marcar como recogido
	var room_path = RoomManager.get_current_room_path()
	GameState.mark_item_collected(room_path, item_id)
	was_collected = true
	is_interactable = false
	
	# Ocultar tile del tilemap
	if hide_tilemap_on_pickup:
		hide_tilemap_tile()
	
	# Mostrar mensaje temporal
	show_pickup_message()
	
	# Eliminar el Area2D (opcional)
	if hide_interactable_on_pickup:
		queue_free()

# ==================== MODO 3: INFO_THEN_ITEM ====================
func show_content_then_give_item() -> void:
	if content_pages.is_empty():
		push_error("❌ No hay texturas asignadas para objeto híbrido: " + name)
		return
	
	# Si ya fue recogido, solo mostrar info
	if was_collected:
		show_content_viewer()
		return
	
	print("📖 Mostrando contenido híbrido: ", name)
	
	var ui_content_type: UIManager.ContentType
	match content_type:
		"nota":
			ui_content_type = UIManager.ContentType.NOTE
		"tablero":
			ui_content_type = UIManager.ContentType.BOARD
		"computador":
			ui_content_type = UIManager.ContentType.COMPUTER
		_:
			ui_content_type = UIManager.ContentType.NOTE
	
	UIManager.show_content(content_pages, ui_content_type)
	
	# Conectar señal para detectar cuando se cierra el viewer
	connect_to_content_viewer_close()

func connect_to_content_viewer_close() -> void:
	await get_tree().process_frame
	
	var viewer = UIManager.content_viewer
	if viewer:
		if not viewer.is_connected("visibility_changed", Callable(self, "_on_viewer_closed")):
			viewer.connect("visibility_changed", Callable(self, "_on_viewer_closed"))

func _on_viewer_closed() -> void:
	var viewer = UIManager.content_viewer
	if viewer and not viewer.visible and not was_collected:
		give_item_after_closing()
		
		# Desconectar señal
		if viewer.is_connected("visibility_changed", Callable(self, "_on_viewer_closed")):
			viewer.disconnect("visibility_changed", Callable(self, "_on_viewer_closed"))

func give_item_after_closing() -> void:
	# Agregar item al inventario
	if not item_key.is_empty():
		GameState.add_item(item_key)
	
	# Marcar como recogido
	var room_path = RoomManager.get_current_room_path()
	GameState.mark_item_collected(room_path, item_id)
	was_collected = true
	# NO cambiar is_interactable para poder seguir leyendo
	
	# Mostrar mensaje temporal
	show_pickup_message()
	
	# Ocultar visual solo si está configurado
	if hide_tilemap_on_pickup:
		hide_tilemap_tile()
	
	# Eliminar el Area2D solo si está configurado
	if hide_interactable_on_pickup:
		is_interactable = false
		queue_free()

# ==================== SISTEMA DE MENSAJES ====================
func show_pickup_message() -> void:
	var message = pickup_message
	
	if message.is_empty():
		message = "Has obtenido: " + item_key.replace("_", " ").capitalize()
	
	# Buscar el InteractingComponent del jugador
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var interact_comp = player.get_node_or_null("InteractingComponent")
		if interact_comp and interact_comp.has_method("show_temporary_message"):
			interact_comp.show_temporary_message(message, 3.0)
		else:
			print("💬 ", message)

# ==================== OCULTAR TILE DEL TILEMAP ====================
func hide_tilemap_tile() -> void:
	if not hide_tilemap_on_pickup:
		return
	
	# Buscar el TileMapLayer en la escena
	var tilemap_layer = find_tilemap_layer_in_scene()
	
	if tilemap_layer == null:
		push_warning("⚠️ No se encontró TileMapLayer: " + tilemap_layer_name)
		return
	
	# Ocultar el tile en las coordenadas especificadas
	tilemap_layer.erase_cell(tile_coords)
	print("🗑️ Tile oculto en capa '" + tilemap_layer_name + "' coords: ", tile_coords)

func find_tilemap_layer_in_scene() -> TileMapLayer:
	# Buscar TileMapLayer en toda la escena (recursivo)
	var root = get_tree().current_scene
	
	# Buscar por nombre exacto
	if not tilemap_layer_name.is_empty():
		var layer = root.find_child(tilemap_layer_name, true, false)
		if layer is TileMapLayer:
			return layer
	
	# Si el Interactable es hijo directo del TileMapLayer, usar el padre
	if get_parent() is TileMapLayer:
		return get_parent()
	
	# Buscar cualquier TileMapLayer
	return find_first_tilemap_layer(root)

func find_first_tilemap_layer(node: Node) -> TileMapLayer:
	if node is TileMapLayer:
		return node
	
	for child in node.get_children():
		var result = find_first_tilemap_layer(child)
		if result:
			return result
	
	return null

# ==================== DEBUG ====================
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	match interaction_mode:
		InteractionMode.INFO_ONLY:
			if content_pages.is_empty():
				warnings.append("INFO_ONLY requiere 'content_pages' configurado")
		
		InteractionMode.ITEM_ONLY:
			if item_key.is_empty():
				warnings.append("ITEM_ONLY requiere 'item_key' configurado")
		
		InteractionMode.INFO_THEN_ITEM:
			if content_pages.is_empty():
				warnings.append("INFO_THEN_ITEM requiere 'content_pages' configurado")
			if item_key.is_empty():
				warnings.append("INFO_THEN_ITEM requiere 'item_key' configurado")
	
	if hide_tilemap_on_pickup and tile_coords == Vector2i(0, 0):
		warnings.append("'hide_tilemap_on_pickup' activado pero 'tile_coords' no configurado")
	
	return warnings
