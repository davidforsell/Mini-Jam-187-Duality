extends Control

@onready var outline = $KnightRect/Outline


func _on_cancel_button_down() -> void:
	visible = false


func _on_knight_rect_mouse_entered() -> void:
	outline.visible = true


func _on_knight_rect_mouse_exited() -> void:
	outline.visible = false

func _process(delta: float) -> void:
	if Playervariables.weapon_cooldown > 0:
		$Cooldown.visible = true
		$Cooldown/RichTextLabel.text = "On cooldown.\n" + str(Playervariables.weapon_cooldown) + " turns left."
	else:
		$Cooldown.visible = false


func _on_knight_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
			Playervariables.weapon_cooldown = 5
			Playervariables.weapon_ability = true
			visible = false
