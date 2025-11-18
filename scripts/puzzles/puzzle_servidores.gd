# Configuración del Puzzle #3 - Acceso al Sistema del Director
# Con pantalla final que permanece abierta hasta cerrar manualmente

extends Node

static func get_puzzle_data() -> Dictionary:
	var base_path = "res://sprites/UI/terminales/terminal_servidores/"
	
	return {
		"puzzle_id": "puzzle_sala_servidores",
		"completed_texture": load(base_path + "terminal_completada.png"),
		
		# ==================== CONFIGURACIÓN DE PANTALLAS ====================
		"show_intro_screen": true,  # No tiene pantalla inicial
		"intro_texture": load(base_path + "terminal_intro.png"),
		"intro_duration": 10.0,  # Duración en segundos
		
		# Pantalla final
		"auto_close_final": false,  # NO se cierra automáticamente
		"final_screen_duration": 3.0,  # Este valor se ignora si auto_close_final es false
		
		# ==================== ETAPAS DEL PUZZLE ====================
		"stages": [
			# ==================== ETAPA 1: if ====================
			{
				"question_texture": load(base_path + "terminal_base.png"),
				"options": [
					{
						"button_text": "Si",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_A_etapa1.png")
					},
					{
						"button_text": "else",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_B_etapa1.png")
					},
					{
						"button_text": "if",
						"font_size": 5,
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_C_etapa1.png")
					},
					{
						"button_text": "entonces",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_D_etapa1.png")
					}
				]
			},
			
			# ==================== ETAPA 2: false ====================
			{
				"question_texture": load(base_path + "terminal_base_etapa2.png"),
				"options": [
					{
						"button_text": "true",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_A_etapa2.png")
					},
					{
						"button_text": "false",
						"font_size": 5,
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_B_etapa2.png")
					},
					{
						"button_text": "si",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_C_etapa2.png")
					},
					{
						"button_text": '"false"',
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_D_etapa2.png")
					}
				]
			}
		]
	}
