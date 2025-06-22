extends Node2D

var textures = [
	load("res://Assets/Player/player_sprite_front.png"),
	load("res://Assets/Player/player_sprite_back.png"),
	load("res://Assets/Player/player_sprite_lor.png"),
]

func _process(delta: float) -> void:
	match Playervariables.orientation:
		Playervariables.Orientation.LEFT:
			$Sprite2D.texture = textures[2]
			$Sprite2D.flip_h = true
		Playervariables.Orientation.RIGHT:
			$Sprite2D.texture = textures[2]
			$Sprite2D.flip_h = false
		Playervariables.Orientation.UP:
			$Sprite2D.texture = textures[1]
		Playervariables.Orientation.DOWN:
			$Sprite2D.texture = textures[0]
