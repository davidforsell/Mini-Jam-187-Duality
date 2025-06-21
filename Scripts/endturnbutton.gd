extends Button

signal endturn


func _on_button_down() -> void:
	emit_signal("endturn")
