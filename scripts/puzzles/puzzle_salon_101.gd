# Configuración del Puzzle #1 - Sistema de Asistencia
# Ahora con textos y tamaños de fuente configurables

extends Node

static func get_puzzle_data() -> Dictionary:
	var base_path = "res://sprites/UI/terminales/terminal_salon_101/"
	
	return {
		"puzzle_id": "puzzle_01_asistencia",
		"completed_texture": load(base_path + "terminal_completada.png"),
		"stages": [
			{
				# Imagen con la pregunta
				"question_texture": load(base_path + "terminal_base.png"),
				"options": [
					{
						"button_text": "nombre_alumno",  # ← NUEVO: Texto del botón
						"font_size": 5,                       # ← NUEVO: Tamaño de fuente
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
						"font_size": 4,  # ← Ejemplo: fuente más pequeña para texto largo
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
