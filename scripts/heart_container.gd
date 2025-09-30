extends HBoxContainer

# Usamos AnimatedTexture para los corazones animados
@export var heart_full_anim: AnimatedTexture   # Corazón lleno (idle animado)
@export var heart_half_anim: AnimatedTexture   # Corazón medio (idle animado)
@export var heart_empty: Texture2D             # Corazón vacío (estático)

var max_hearts: int = 3  # El jugador tiene 30 de vida → 3 corazones

func update_hearts(current_health: int) -> void:
	var full_hearts = current_health / 10
	var has_half = (current_health % 10) >= 5

	for i in range(max_hearts):
		var heart = get_child(i) as TextureRect

		if i < full_hearts:
			# Corazón lleno animado
			heart.texture = heart_full_anim
		elif i == full_hearts and has_half:
			# Corazón a la mitad animado
			heart.texture = heart_half_anim
		else:
			# Corazón vacío (sin animación)
			heart.texture = heart_empty
