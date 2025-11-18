# Configuración del Puzzle Lab Robótica - Sistema de Acceso al Arsenal
# Oculta GunLayer y spawns lasergun al completarse

extends Node

static func get_puzzle_data() -> Dictionary:
	var base_path = "res://sprites/UI/terminales/terminal_lab_robotica/"
	
	return {
		"puzzle_id": "puzzle_lab_robotica",
		"completed_texture": load(base_path + "terminal_completada.png"),
		
		# ==================== CONFIGURACIÓN DE PANTALLAS ====================
		"show_intro_screen": false,  
		#"intro_texture": load(base_path + "terminal_intro.png"),
		#"intro_duration": 5.0,  # Duración en segundos
		
		# Pantalla final
		"auto_close_final": false,  #se cierra automáticamente
		"final_screen_duration": 3.0,  # Este valor se ignora si auto_close_final es false
		
		# ==================== ETAPAS DEL PUZZLE ====================
		"stages": [
			# ==================== ETAPA 1: Nombre del docente ====================
			{
				"question_texture": load(base_path + "terminal_base.png"),
				"options": [
					{
						"button_text": '"Wilson Alfonso"',
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_A_etapa1.png")
					},
					{
						"button_text": '"Rafael Mantilla"',
						"font_size": 5,
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_B_etapa1.png")
					},
					{
						"button_text": "Rafael Mantilla",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_C_etapa1.png")
					},
					{
						"button_text": '"Alexandra Soraya"',
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_D_etapa1.png")
					}
				]
			},
			
			# ==================== ETAPA 2: Nombre de variable ====================
			{
				"question_texture": load(base_path + "terminal_base_etapa2.png"),
				"options": [
					{
						"button_text": "1contraseña",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_A_etapa2.png")
					},
					{
						"button_text": "apodo",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_B_etapa2.png")
					},
					{
						"button_text": "contraseña",
						"font_size": 5,
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_C_etapa2.png")
					},
					{
						"button_text": "la contraseña",
						"font_size": 5,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_D_etapa2.png")
					}
				]
			}
		]
	}
