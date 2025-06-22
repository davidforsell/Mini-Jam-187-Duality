extends Node

enum Orientation {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var orientation: Playervariables.Orientation
var move: bool = false
var mouse_move: bool = false

var class_cooldown: int = 0
var weapon_cooldown: int = 0

var class_ability = false
var weapon_ability = false
