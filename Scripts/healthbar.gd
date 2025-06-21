extends TextureRect

var health_path = "res://Assets/Health Bar/"
var textures = []


func _ready() -> void:
	for i in 20:
		textures.append(load(health_path + "health" + str(i + 1) + ".png"))
	texture = textures[19]
