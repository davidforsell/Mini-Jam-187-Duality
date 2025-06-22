extends Sprite2D

class_name Enemy

const Constants = preload("res://Scripts/constants.gd")

signal attack_player(damage: int)
signal dead

var textures: Dictionary = {
	Constants.EnemyType.RAT: load("res://Assets/Enemies/rat_sprite_v1.png"),
	Constants.EnemyType.GHOUL: load("res://Assets/Enemies/amalgamation_sprite_v2.png"),
	Constants.EnemyType.IMP: load("res://Assets/Enemies/imp_sprite_v1.png"),
	Constants.EnemyType.SLIME: load("res://Assets/Enemies/slime_sprite_v2.png")
}

var attack_funcs = {
	Constants.EnemyType.RAT: rat_attack,
	Constants.EnemyType.GHOUL: ghoul_attack,
	Constants.EnemyType.IMP: imp_attack,
	Constants.EnemyType.SLIME: slime_attack
}

var type: Constants.EnemyType
var rng = RandomNumberGenerator.new()
var health = 0

func _ready() -> void:
	texture = textures[type]
	if health == 0:
		match type:
			Constants.EnemyType.RAT:
				health = 13
			Constants.EnemyType.GHOUL:
				health = 20
			Constants.EnemyType.SLIME:
				health = 15
			Constants.EnemyType.IMP:
				health = 17

func damage(dmg: int):
	DamageNumbers.display_number(dmg, $DamageNumbersOrigin.global_position, dmg >= health)
	health -= dmg
	SfxPlayer.play_sound_effect_from_library("hit")
	if health <= 0:
		emit_signal("dead")

func attack():
	attack_funcs[type].call()

func rat_attack():
	var dmg = rng.randi_range(1, 3)
	emit_signal("attack_player", dmg)
	SfxPlayer.play_sound_effect_from_library("rat_attack")

func ghoul_attack():
	var dmg = rng.randi_range(2, 4)
	emit_signal("attack_player", dmg)
	SfxPlayer.play_sound_effect_from_library("special_hit")

func imp_attack():
	var dmg = rng.randi_range(2, 4)
	emit_signal("attack_player", dmg)
	SfxPlayer.play_sound_effect_from_library("imp_attack")

func slime_attack():
	var dmg = rng.randi_range(1, 3)
	emit_signal("attack_player", dmg)
	SfxPlayer.play_sound_effect_from_library("slime_attack")
