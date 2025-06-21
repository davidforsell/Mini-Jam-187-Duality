extends Sprite2D

@onready var active = load("res://Assets/SigilRingActive.png")
@onready var inactive = load("res://Assets/SigilRingInactive.png")
@onready var player = $Player


var player_on = true
var mouse_on = false

func set_player(value: bool):
	player_on = value
	player.visible = value

func _on_player_moved():
	player_on = false
	player.visible = false

func _on_area_2d_mouse_entered() -> void:
	mouse_on = true
	texture = active

func _on_area_2d_mouse_exited() -> void:
	mouse_on = false
	texture = inactive


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			get_parent().move_player(-1, -1)
