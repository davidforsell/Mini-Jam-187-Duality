class_name Tile

extends Sprite2D

@onready var player = $Player
@onready var selected = load("res://Assets/TileSelected.png")
@onready var deselected = load("res://Assets/Tile.png")
@onready var enemy = preload("res://Scenes/Enemy.tscn")
@onready var locations: Array[Marker2D] = [$EnemyLocation1, $EnemyLocation2, $EnemyLocation3, $EnemyLocation4]

var sigil_neighbour = -1
var max_enemies = 1
var enemy_count = 0
var enemies = []
var tiles: Array[Tile] = []
var TILE_LEFT: Tile
var TILE_RIGHT: Tile
var TILE_UP: Tile
var TILE_DOWN: Tile
var tile_pos = Vector2()
var enemy_buffer = false

var player_on = false
signal player_moved

func set_player(value):
	player_on = value
	player.visible = value

func _mouse_entered() -> void:
	texture = selected

func _on_player_moved():
	player_on = false
	player.visible = false

func _ready():
	# manage tile if next to sigil
	if sigil_neighbour != -1:
		max_enemies = 1
	if sigil_neighbour == 1:
		var t = locations[0]
		locations[0] = locations[3]
		locations[3] = t
	if sigil_neighbour == 2:
		var t = locations[1]
		locations[1] = locations[3]
		locations[3] = t
	if sigil_neighbour == 3:
		var t = locations[2]
		locations[2] = locations[3]
		locations[3] = t

func add_enemy() -> bool:
	if enemy_count >= max_enemies:
		return false
	enemy_count += 1
	enemy_buffer = true
	return true

func _move_enemies(player_pos: Vector2):
	if enemy_count == 0 || enemy_buffer:
		return
	var dx = tile_pos.x - player_pos.x
	var dy = tile_pos.y - player_pos.y
	if player_pos.x == -1:
		dx = tile_pos.x - 2.5
		dy = tile_pos.y - 2.5
	print(dx)
	print(dy)
	
	if abs(dx) > abs(dy):
		# Move horizontally
		if dx > 0:
			# one tile left
			if TILE_LEFT != null:
				if TILE_LEFT.add_enemy():
					var en = enemies.pop_back()
					en.queue_free()
					enemy_count -= 1
		else:
			# one tile right
			if TILE_RIGHT != null:
				if TILE_RIGHT.add_enemy():
					var en = enemies.pop_back()
					en.queue_free()
					enemy_count -= 1
	elif abs(dy) > abs(dx):
		#Move vertically
		if dy > 0:
			# one tile up
			if TILE_UP != null:
				if TILE_UP.add_enemy():
					var en = enemies.pop_back()
					en.queue_free()
					enemy_count -= 1
		else:
			# one tile up
			if TILE_DOWN != null:
				if TILE_DOWN.add_enemy():
					var en = enemies.pop_back()
					en.queue_free()
					enemy_count -= 1
	elif abs(dx) > 0.5 or abs(dy) > 0.5:
		#They are the same, move randomly
		var rng = RandomNumberGenerator.new()
		if rng.randf() > 0.5:
			# move vertical
			if dx > 0:
				# move left
				if TILE_LEFT != null:
					if TILE_LEFT.add_enemy():
						enemies.pop_back().queue_free()
						enemy_count -= 1
			else:
				if TILE_RIGHT != null:
					if TILE_RIGHT.add_enemy():
						enemies.pop_back().queue_free()
						enemy_count -= 1
				# move right
		else:
			if dy > 0:
				# move down
				if TILE_UP != null:
					if TILE_UP.add_enemy():
						enemies.pop_back().queue_free()
						enemy_count -= 1
			else:
				if TILE_DOWN != null:
					if TILE_DOWN.add_enemy():
						enemies.pop_back().queue_free()
						enemy_count -= 1
			
			
	else:
		#attack
		pass

func _on_run_buffers():
	if enemy_buffer:
		print("This happened")
		var en: Node2D = enemy.instantiate()
		en.scale = Vector2(0.25, 0.25)
		en.position = locations[enemy_count].position
		add_child(en)
		enemies.append(en)
		enemy_buffer = false

func _on_end_turn(player_pos: Vector2):
	_move_enemies(player_pos)

func _mouse_exited() -> void:
	texture = deselected
