extends Control

func _ready() -> void:
	# Asegurar que funcione mientras el juego está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

# Método para establecer texto (opcional, si quieres control específico)
func set_text(text: String) -> void:
	# Asume que tienes un Label o RichTextLabel en tu UI
	if has_node("Label"):
		$Label.text = text
	elif has_node("RichTextLabel"):
		$RichTextLabel.text = text
	elif has_node("Panel/Label"):
		$Panel/Label.text = text
