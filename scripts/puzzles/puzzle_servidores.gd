# Configuración del Puzzle #3 - Acceso al Sistema del Director
# Este puzzle tiene 2 etapas y muestra info del director al completarse

extends Node

static func get_puzzle_data() -> Dictionary:
	# Cargar texturas desde la carpeta del puzzle
	var base_path = "res://sprites/UI/terminales/terminal_servidores/"
	
	return {
		"puzzle_id": "puzzle_03_direccion",
		"completed_texture": load(base_path + "terminal_completada.png"),  # Info del director
		"stages": [
			# ==================== ETAPA 1: if ====================
			{
				"question_texture": load(base_path + "terminal_base.png"),
				"options": [
					{
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_A_etapa1.png")
					},
					{
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_B_etapa1.png")
					},
					{
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_C_etapa1.png")
					},
					{
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
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_A_etapa2.png")
					},
					{
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_B_etapa2.png")
					},
					{
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_C_etapa2.png")
					},
					{
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_D_etapa2.png")
					}
				]
			}
		]
	}
