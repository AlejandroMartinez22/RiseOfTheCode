extends CanvasLayer

func _ready():
	self.hide()

func game_over():
	get_tree().paused = true
	self.show() 

# reintentar
func _on_button_2_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# salir
func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu/main_menu.tscn")
