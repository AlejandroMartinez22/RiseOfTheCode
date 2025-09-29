extends HBoxContainer

# Exportamos las texturas de cada estado del corazón
@export var heart_full: Texture2D      # Corazón lleno
@export var heart_half: Texture2D      # Corazón a la mitad
@export var heart_empty: Texture2D     # Corazón vacío

# Número máximo de corazones (el jugador tiene 30 de vida, cada corazón son 10)
var max_hearts: int = 3

func update_hearts(current_health: int) -> void:
	# Esta función actualiza la UI en base a la vida actual del jugador.

	# Cuántos corazones enteros tiene el jugador
	var full_hearts = current_health / 10
	
	# Si sobra vida que no llega a 10, revisamos si al menos son 5 → medio corazón
	var has_half = (current_health % 10) >= 5

	# Recorremos cada TextureRect hijo dentro del HBoxContainer
	for i in range(max_hearts):
		var heart = get_child(i) as TextureRect
		
		if i < full_hearts:
			# Si está dentro de los corazones llenos
			heart.texture = heart_full
		elif i == full_hearts and has_half:
			# Si justo en este índice va el corazón a la mitad
			heart.texture = heart_half
		else:
			# Si no, está vacío
			heart.texture = heart_empty
