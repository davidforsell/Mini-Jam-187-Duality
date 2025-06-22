extends Node

func is_mouse_over_ui() -> bool:
	var hovered = get_viewport().gui_get_hovered_control()
	return hovered != null

func _input(event):
	if event.is_action_pressed("A") && !event.is_echo():
		Playervariables.orientation = Playervariables.Orientation.LEFT
	elif event.is_action_pressed("D") && !event.is_echo():
		Playervariables.orientation = Playervariables.Orientation.RIGHT
	elif event.is_action_pressed("S") && !event.is_echo():
		Playervariables.orientation = Playervariables.Orientation.DOWN
	elif event.is_action_pressed("W") && !event.is_echo():
		Playervariables.orientation = Playervariables.Orientation.UP
	elif event.is_action_pressed("MOVE") && !event.is_echo():
		Playervariables.move = true
	elif event.is_action_pressed("Class Ability") && !event.is_echo():
		get_node("../CanvasLayer/ClassAbilitySelect").visible = true
	elif event.is_action_pressed("Weapon Ability") && !event.is_echo():
		get_node("../CanvasLayer/WeaponAbilitySelect").visible = true
	elif event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed && !is_mouse_over_ui():
		Playervariables.mouse_move = true
