extends Control

func _on_knight_rect_mouse_entered() -> void:
	$Mettle/Outline.visible = true


func _on_knight_rect_mouse_exited() -> void:
	$Mettle/Outline.visible = false

func _process(delta: float) -> void:
	if Playervariables.class_cooldown > 0:
		$Cooldown.visible = true
		$Cooldown/RichTextLabel.text = "On cooldown.\n" + str(Playervariables.class_cooldown) + " turns left."
	else:
		$Cooldown.visible = false


func _on_cancel_button_down() -> void:
	visible = false


func _on_mettle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
			Playervariables.class_cooldown = 5
			Playervariables.class_ability = true
			visible = false
