extends CanvasLayer

# Carga las escenas de UI (ajusta las rutas según tu proyecto)
@onready var carta_ui_scene = preload("res://sprites/UI/modelo_carta.tscn")
@onready var tablero_ui_scene = preload("res://ui/TableroUI.tscn")
@onready var terminal_ui_scene = preload("res://ui/TerminalUI.tscn")

var current_ui: Control = null

func show_ui(type: String, text: String = ""):
	# Cierra cualquier UI anterior
	if current_ui and is_instance_valid(current_ui):
		current_ui.queue_free()
	
	var new_ui: Control = null
	
	match type:
		"carta":
			new_ui = carta_ui_scene.instantiate()
		"tablero":
			new_ui = tablero_ui_scene.instantiate()
		"terminal":
			new_ui = terminal_ui_scene.instantiate()
		_:
			printerr("Tipo de UI desconocido: ", type)
			return
	
	add_child(new_ui)
	current_ui = new_ui
	
	# Si la UI tiene un método 'show_with_text', lo llamamos
	if new_ui.has_method("show_with_text"):
		new_ui.call_deferred("show_with_text", text)
	
	print("✅ Mostrando UI:", type)

func hide_ui():
	if current_ui and is_instance_valid(current_ui):
		current_ui.queue_free()
		current_ui = null
