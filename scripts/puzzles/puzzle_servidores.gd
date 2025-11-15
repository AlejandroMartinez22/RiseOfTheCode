# Configuración del Puzzle #3 - Acceso al Sistema del Director
# Con textos y tamaños de fuente configurables en ambas etapas

extends Node

static func get_puzzle_data() -> Dictionary:
	var base_path = "res://sprites/UI/terminales/terminal_servidores/"
	
	return {
		"puzzle_id": "puzzle_03_direccion",
		"completed_texture": load(base_path + "terminal_completada.png"),
		"stages": [
			# ==================== ETAPA 1: if ====================
			{
				"question_texture": load(base_path + "terminal_base.png"),
				"options": [
					{
						"button_text": "[A] si",
						"font_size": 10,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_A_etapa1.png")
					},
					{
						"button_text": "[B] else",
						"font_size": 10,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_B_etapa1.png")
					},
					{
						"button_text": "[C] if",
						"font_size": 10,
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_C_etapa1.png")
					},
					{
						"button_text": "[D] entonces",
						"font_size": 9,
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
						"button_text": "[A] true",
						"font_size": 10,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_A_etapa2.png")
					},
					{
						"button_text": "[B] false",
						"font_size": 10,
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_B_etapa2.png")
					},
					{
						"button_text": "[C] si",
						"font_size": 10,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_C_etapa2.png")
					},
					{
						"button_text": "[D] \"false\"",
						"font_size": 9,
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_D_etapa2.png")
					}
				]
			}
		]
	}
