class_name Tile

extends Sprite2D

@onready var player = $Player
@onready var selected = load("res://Assets/tile_selected.png")
@onready var deselected = load("res://Assets/tile_unselected.png")
@onready var enemy = preload("res://Scenes/Enemy.tscn")
@onready var locations: Array[Marker2D] = [$EnemyLocation]
@onready var main = get_node("..")
@onready var healing_orb = load("res://Assets/Orbs/healing_orb.png")
@onready var ghost_orb = load("res://Assets/Orbs/ghost_orb.png")

const Constants = preload("res://Scripts/constants.gd")

var sigil_neighbour = -1
var max_enemies = 1
var enemy_count = 0
var enemies: Array[Enemy] = []
var TILE_LEFT: Tile
var TILE_RIGHT: Tile
var TILE_UP: Tile
var TILE_DOWN: Tile
var tile_pos = Vector2()
var enemy_buffer = false
var type: Constants.EnemyType
var tileType: int
var enemy_health: int = 0

var orb: int = 0


var player_on = false
signal player_moved
signal orb_collect(type)
signal enemy_died

func set_player(value):
	player_on = value
	player.visible = value
	if value == true:
		if orb == 1:
			$Orb.queue_free()
			emit_signal("orb_collect", 1)
			orb = 0
		elif orb == 2:
			$Orb.queue_free()
			emit_signal("orb_collect", 2)
			orb = 0

func _mouse_entered() -> void:
	texture = selected

func _on_player_moved():
	player_on = false
	player.visible = false

func _ready():
	# manage tile if next to sigil
	
	if tileType == 0:
		$Label.text = "B"
	elif tileType == 1:
		$Label.text = "1"
	elif tileType == 2:
		$Label.text = "2"
	elif tileType == 3:
		$Label.text = "3"
		
	if orb == 1:
		$Orb.texture = ghost_orb
	elif orb == 2:
		$Orb.texture = healing_orb

func add_enemy(type: Constants.EnemyType, health: int) -> bool:
	if enemy_count >= max_enemies || player_on:
		return false
	self.type = type
	enemy_count += 1
	enemy_health = health
	enemy_buffer = true
	return true

func damage_enemy(damage: int):
	if enemy_count != 0:
		enemies.back().damage(damage)

func _move_rand(ignore: int):
	var tiles: Array[Tile] = [TILE_LEFT, TILE_RIGHT, TILE_UP, TILE_DOWN]
	var existing_tiles = []
	tiles.remove_at(ignore)
	
	for tile in tiles:
		if tile != null:
			existing_tiles.append(tile)
	if len(existing_tiles) == 0:
		return
	if existing_tiles.pick_random().add_enemy(enemies.back().type, enemies.back().health):
		_consume_enemy()

func _consume_enemy():
	var en = enemies.pop_back()
	en.queue_free()
	enemy_count -= 1

func _move_enemies(player_pos: Vector2):
	if enemy_count == 0 || enemy_buffer:
		return
	var dx = tile_pos.x - player_pos.x
	var dy = tile_pos.y - player_pos.y
	if player_pos.x == -1:
		dx = tile_pos.x - 3.5
		dy = tile_pos.y - 3.5
		
	if abs(dx) <= 1 && abs(dy) <= 1 && (!(abs(dx) == 1 && abs(dy) == 1)):
		_attack()
		return
	
	if abs(dx) > abs(dy):
		# Move horizontally
		if dx > 0:
			# one tile left
			if TILE_LEFT != null && TILE_LEFT.add_enemy(enemies.back().type, enemies.back().health):
				_consume_enemy()
			elif abs(dx) > 2 || abs(dy) > 2:
				_move_rand(0)
		else:
			# one tile right
			if TILE_RIGHT != null && TILE_RIGHT.add_enemy(enemies.back().type, enemies.back().health):
				_consume_enemy()
			elif abs(dx) > 2 || abs(dy) > 2:
				_move_rand(1)
	elif abs(dy) > abs(dx):
		#Move vertically
		if dy > 0:
			# one tile up
			if TILE_UP != null && TILE_UP.add_enemy(enemies.back().type, enemies.back().health):
				_consume_enemy()
			elif abs(dx) > 2 || abs(dy) > 2:
				_move_rand(2)
		else:
			# one tile up
			if TILE_DOWN != null && TILE_DOWN.add_enemy(enemies.back().type, enemies.back().health):
				_consume_enemy()
			elif abs(dx) > 2 || abs(dy) > 2:
				_move_rand(3)
	elif abs(dx) > 0.5 or abs(dy) > 0.5:
		#They are the same, move randomly
		var rng = RandomNumberGenerator.new()
		if rng.randf() > 0.5:
			# move vertical
			if dx > 0:
				# move left
				if TILE_LEFT != null && TILE_LEFT.add_enemy(enemies.back().type, enemies.back().health):
					_consume_enemy()
				elif abs(dx) > 2 || abs(dy) > 2:
					_move_rand(0)
			else:
				if TILE_RIGHT != null && TILE_RIGHT.add_enemy(enemies.back().type, enemies.back().health):
					_consume_enemy()
				elif abs(dx) > 2 || abs(dy) > 2:
					_move_rand(1)
				# move right
		else:
			if dy > 0:
				# move down
				if TILE_UP != null && TILE_UP.add_enemy(enemies.back().type, enemies.back().health):
					_consume_enemy()
				elif abs(dx) > 2 || abs(dy) > 2:
					_move_rand(2)
			else:
				if TILE_DOWN != null && TILE_DOWN.add_enemy(enemies.back().type, enemies.back().health):
					_consume_enemy()
				elif abs(dx) > 2 || abs(dy) > 2:
					_move_rand(3)

func _attack():
	enemies.back().attack()

func _on_death():
	_consume_enemy()
	emit_signal("enemy_died")

func _on_run_buffers():
	if enemy_buffer:
		var en: Enemy = enemy.instantiate()
		en.scale = Vector2(1.0, 1.0)
		en.position = locations[0].position
		en.type = type
		en.dead.connect(self._on_death)
		en.health = enemy_health
		add_child(en)
		enemies.append(en)
		en.attack_player.connect(main._on_damage)
		
		enemy_buffer = false

func _on_end_turn(player_pos: Vector2):
	_move_enemies(player_pos)

func _mouse_exited() -> void:
	texture = deselected
