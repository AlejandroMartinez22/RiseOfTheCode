extends HBoxContainer

#Usamos AnimatedTexture para los corazones animados
@export var heart_full_anim: AnimatedTexture   # Corazón lleno (animación de latido)
@export var heart_half_anim: AnimatedTexture   # Corazón medio (animación de latido)
@export var heart_empty: Texture2D             # Corazón vacío (estático)

var max_hearts: int = 3  # El jugador tiene 30 de vida (3 corazones)

func update_hearts(current_health: int) -> void:
	var full_hearts = current_health / 10
	var has_half = (current_health % 10) >= 5

	for i in range(max_hearts):
		var heart = get_child(i) as TextureRect

		if i < full_hearts:
			heart.texture = heart_full_anim # Corazón lleno animado
		elif i == full_hearts and has_half:
			heart.texture = heart_half_anim # Corazón a la mitad animado
		else:
			heart.texture = heart_empty # Corazón vacío (sin animación)
