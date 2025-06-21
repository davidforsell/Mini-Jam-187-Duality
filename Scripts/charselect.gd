extends Control


func _on_knight_rect_mouse_entered() -> void:
	$KnightRect/Outline.visible = true


func _on_knight_rect_mouse_exited() -> void:
	$KnightRect/Outline.visible = false


func _on_knight_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().change_scene_to_file("res://Scenes/main.tscn")
