extends Control


var textures = [
	load("res://Assets/Knightfall_Menu1.png"),
	load("res://Assets/Knightfall_Menu2.png"),
	load("res://Assets/Knightfall_Menu3.png")
]

func _on_play_button_mouse_entered() -> void:
	$TextureRect.texture = textures[1]



func _on_play_button_mouse_exited() -> void:
	$TextureRect.texture = textures[0]


func _on_credits_button_mouse_entered() -> void:
	$TextureRect.texture = textures[2]


func _on_credits_button_mouse_exited() -> void:
	$TextureRect.texture = textures[0]


func _on_play_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_file("res://Scenes/select/charselect.tscn")


func _on_credits_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
