class_name Player

var moved: bool = false
var attacked: bool = false
var pos: Vector2 = Vector2()

var AP: int = 20

var abilities = []

func end_turn():
	if !moved:
		AP = min(20, AP + 2)
	if !attacked:
		AP = min(20, AP + 4)
	moved = false
	attacked = false

func _init(pos: Vector2):
	self.pos = pos
