class_name Player

var moved: bool = false
var attacked: bool = false
var pos: Vector2 = Vector2()
var cursed: bool = false

var AP: int = 20 : set = _set_ap
var health: int = 20 : set = _set_health
var corruption: int = 0 : set = _set_corruption
var curse: int = 0 : set = _set_curse

var abilities = []

func _set_corruption(new_corruption: int):
	corruption = min(5, new_corruption)
	corruption = max(0, corruption)

func _set_curse(new_curse: int):
	curse = min(20, new_curse)
	curse = max(0, curse)

func _set_health(new_health: int):
	health = min(20, new_health)
	health = max(0, health)
	print(health)

func _set_ap(new_ap: int):
	AP = min(20, new_ap)
	AP = max(0, AP)

func end_turn():
	if !moved:
		AP = min(20, AP + 2)
	if !attacked:
		AP = min(20, AP + 4)
	if cursed:
		corruption += 1
	moved = false
	attacked = false
	cursed = false
	
	Playervariables.class_cooldown = max(0, Playervariables.class_cooldown - 1)
	Playervariables.weapon_cooldown = max(0, Playervariables.weapon_cooldown - 1)

func _init(pos: Vector2):
	self.pos = pos

func ap_check(AP: int) -> bool:
	if self.AP - AP >= 0:
		return true
	else:
		return false

func damage(dmg: int):
	health = max(0, health - dmg)
