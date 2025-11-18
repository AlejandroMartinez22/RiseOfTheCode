# Configuración del Puzzle #1 - Sistema de Asistencia
# Con pantalla final de 3 segundos que se cierra automáticamente

extends Node

static func get_puzzle_data() -> Dictionary:
	var base_path = "res://sprites/UI/terminales/terminal_salon_101/"
	
	return {
		"puzzle_id": "puzzle_salon_101",
		"completed_texture": load(base_path + "terminal_completada.png"),
		
		# ==================== CONFIGURACIÓN DE PANTALLAS ====================
		# Pantalla inicial (opcional)
		"show_intro_screen": false,  # No tiene pantalla inicial
		# "intro_texture": load(base_path + "intro.png"),  # Descomentar si se quiere usar
		# "intro_duration": 2.0,  # Duración en segundos
		
		# Pantalla final
		"auto_close_final": true,  # Se cierra automáticamente
		"final_screen_duration": 3.0,  # Duración antes de cerrar
		
		# ==================== ETAPAS DEL PUZZLE ====================
		"stages": [
			{
				# Imagen con la pregunta
				"question_texture": load(base_path + "terminal_base.png"),
				"options": [
					{
						"button_text": "nombre_alumno",
						"font_size": 5,
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_A.png")
					},
					{
						"button_text": "edad_alumno",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_B.png")
					},
					{
						"button_text": "nombre completo",
						"font_size": 4,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_C.png")
					},
					{
						"button_text": "1nombre",
						"font_size": 6,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_D.png")
					}
				]
			}
		]
	}
