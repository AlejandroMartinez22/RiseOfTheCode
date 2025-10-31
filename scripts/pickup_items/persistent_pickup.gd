# Sistema para objetos recogibles con persistencia
# Maneja llaves, armas, y cualquier item que el jugador deba recoger
extends Area2D

# ==================== CONFIGURACIÓN DEL ITEM ====================
@export var item_id: String = ""              # ID único del item (ej: "llave_director_oficina")
@export var item_key: String = ""             # Clave en el inventario (ej: "llave_director")
@export var pickup_message: String = ""       # Mensaje al recoger (ej: "Has obtenido la llave del director")

# ==================== TIPO DE ITEM ====================
enum ItemType {
	KEY,            # Llave u objeto de inventario
	WEAPON,         # Arma que se equipa
	CONSUMABLE,     # Consumible (corazón, etc.)
	QUEST_ITEM      # Item de misión
}

@export var item_type: ItemType = ItemType.KEY

# ==================== PARA ARMAS ====================
@export var weapon_resource: Resource = null  # Recurso de tipo Weapon

# ==================== VISUAL Y AUDIO ====================
@onready var sprite: Sprite2D = $Sprite2D
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

func _ready() -> void:
	# Auto-generar ID si no está configurado
	if item_id.is_empty():
		item_id = name
	
	# Verificar si este item ya fue recogido
	var room_path = RoomManager.get_current_room_path()
	if GameState.is_item_collected(room_path, item_id):
		queue_free()  # Eliminarse inmediatamente
		return
	
	# Conectar señal
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	# Procesar el pickup según el tipo
	match item_type:
		ItemType.KEY, ItemType.QUEST_ITEM:
			pickup_key_item(body)
		
		ItemType.WEAPON:
			pickup_weapon(body)
		
		ItemType.CONSUMABLE:
			pickup_consumable(body)
	
	# Registrar que este item fue recogido
	var room_path = RoomManager.get_current_room_path()
	GameState.mark_item_collected(room_path, item_id)
	
	# Efectos visuales/sonoros
	play_pickup_effects()
	
	# Destruir el item
	queue_free()

func pickup_key_item(player: Node) -> void:
	# Agregar al inventario
	if not item_key.is_empty():
		GameState.add_item(item_key)
	
	# Mostrar mensaje
	if not pickup_message.is_empty():
		show_pickup_message(pickup_message)
	else:
		show_pickup_message("Has obtenido: " + item_key.replace("_", " ").capitalize())

func pickup_weapon(player: Node) -> void:
	if weapon_resource == null:
		push_error("Item de tipo WEAPON no tiene weapon_resource configurado")
		return
	
	# Equipar el arma al jugador
	if player.has_method("equip_weapon"):
		player.equip_weapon(weapon_resource)
	
	# Agregar al inventario en GameState
	if not item_key.is_empty():
		GameState.add_item(item_key)
	
	# Mostrar mensaje
	if not pickup_message.is_empty():
		show_pickup_message(pickup_message)
	else:
		show_pickup_message("Has obtenido: " + weapon_resource.name)

func pickup_consumable(player: Node) -> void:
	# Los consumibles no se registran en inventario, solo se usan
	# (Por ejemplo, un corazón)
	if player.has_method("heal"):
		player.heal(10)  # O el valor que corresponda
	
	if not pickup_message.is_empty():
		show_pickup_message(pickup_message)

func play_pickup_effects() -> void:
	# Reproducir sonido
	if pickup_sound and pickup_sound.stream:
		pickup_sound.play()
	
	# Animación simple (opcional)
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.3)

func show_pickup_message(message: String) -> void:
	print("✓ ", message)
	# TODO: Implementar notificación en UI
	# UIManager.show_notification(message)

# ==================== DEBUG ====================
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if item_key.is_empty() and item_type != ItemType.CONSUMABLE:
		warnings.append("'item_key' está vacío. Este item no se agregará al inventario.")
	
	if item_type == ItemType.WEAPON and weapon_resource == null:
		warnings.append("Item de tipo WEAPON pero 'weapon_resource' no está configurado")
	
	return warnings
