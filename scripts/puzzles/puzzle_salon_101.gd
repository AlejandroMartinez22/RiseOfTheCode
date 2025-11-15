# Configuración del Puzzle #1 - Sistema de Asistencia
# Este puzzle tiene 1 sola etapa y NO desencadena recompensas

extends Node

static func get_puzzle_data() -> Dictionary:
	# Cargar texturas desde la carpeta del puzzle
	var base_path = "res://sprites/UI/terminales/terminal_salon_101/terminal_base"
	
	return {
		"puzzle_id": "puzzle_01_asistencia",
		"stages": [
			{
				"question_texture": load(base_path + "pregunta.png"),
				"options": [
					{
						"is_correct": true,
						"feedback_texture": load(base_path + "feedback_A.png")
					},
					{
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_B.png")
					},
					{
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_C.png")
					},
					{
						"is_correct": false,
						"feedback_texture": load(base_path + "feedback_D.png")
					}
				]
			}
		]
	}
