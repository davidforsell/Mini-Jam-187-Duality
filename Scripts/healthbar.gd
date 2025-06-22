extends TextureRect

var health_path = "res://Assets/Health Bar/"
var textures = []
var health_damage_tex = load("res://Assets/Health Bar/healthring_damage.png")


func _ready() -> void:
	for i in 20:
		textures.append(load(health_path + "health" + str(i + 1) + ".png"))
	texture = textures[19]

func set_health(health: int, damage = true):
	if damage:
		texture = health_damage_tex
		$Timer.start(0.25)
		await $Timer.timeout
	texture = textures[health - 1]
