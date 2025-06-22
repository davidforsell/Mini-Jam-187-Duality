extends Node2D

@onready var tile = preload("res://Scenes/tile.tscn")
@onready var cam = $Camera2D
@onready var sigil = $SigilCircle
@onready var cursebar = $CanvasLayer/Control/Cursebar
@onready var actionbar = $CanvasLayer/action/Actionbar
@onready var healthbar = $CanvasLayer/Healthbar
@onready var corruptioncounter = $CanvasLayer/Control/Cursebar/Counter


const Constants = preload("res://Scripts/constants.gd")

signal player_moved
signal end_turn(player_pos: Vector2)
signal run_buffers

var TILE_SCALE = 2.0
var tile_array: Array[Tile] = []
var player_pos: Array[int] = [-1, -1]
var enemy_load_buffer: Array[int] = []

var player = Player.new(Vector2(-1, -1))
var GRID_WIDTH = 8

var enemy_count = 0
var dmg_mul = 1.0

var tile_map = {}

var wave = 0
var enemies = [6, 8, 10]

func _populate_tile_map():
	var counter: int = 0
	for i in GRID_WIDTH:
		tile_map[counter] = Vector2(i, 0)
		counter += 1
	for i in GRID_WIDTH:
		tile_map[counter] = Vector2(GRID_WIDTH - 1, i)
		counter += 1
	for i in GRID_WIDTH:
		tile_map[counter] = Vector2(i, GRID_WIDTH - 1)
		counter += 1
	for i in GRID_WIDTH:
		tile_map[counter] = Vector2(0, i)
		counter += 1

func _on_orb_collect(type):
	if type == 1:
		player.AP += 5
		actionbar.set_health_with_timer(player.AP)
		player.curse -= 5
		cursebar.set_health_with_timer(player.curse)
		player.corruption -= 2
		corruptioncounter.set_value(player.corruption)
	elif type == 2:
		player.health += 2
		healthbar.set_health(player.health, false)
		player.corruption -= 1
		corruptioncounter.set_value(player.corruption)

func _ready() -> void:
	get_tree().root.size_changed.connect(self._on_window_resized)
	_populate_tile_map()
	print(get_viewport().get_visible_rect().size)
	
	corruptioncounter.set_value(0)
	
	self.player_moved.connect(sigil._on_player_moved)
	
	actionbar.init_health(20)
	cursebar.init_health(20)
	cursebar.set_health(0)
	var rng = RandomNumberGenerator.new()
	var IMG_SIZE = 100
	# Load tiles
	for row in 8:
		for col in 8:
			var sigval = -1
			if row == 3 and col == 3:
				sigval = 2
			elif row == 4 and col == 3:
				sigval = 3
			elif row == 3 and col == 4:
				sigval = 0
			elif row == 4 and col == 4:
				sigval = 1
			var coords = Vector2(row * IMG_SIZE * TILE_SCALE - 3.5 * IMG_SIZE * TILE_SCALE, col * IMG_SIZE * TILE_SCALE - 3.5 * IMG_SIZE * TILE_SCALE)
			var tileInstance: Sprite2D = tile.instantiate()
			tileInstance.global_position = coords
			tileInstance.tile_pos = Vector2(row, col)
			tileInstance.scale = Vector2(TILE_SCALE, TILE_SCALE)
			tileInstance.sigil_neighbour = sigval
			tileInstance.orb_collect.connect(self._on_orb_collect)
			tileInstance.enemy_died.connect(self._on_enemy_death)
			
			if row == 0 or row == 7 or col == 0 or col == 7:
				if rng.randf() < 0.15:
					tileInstance.tileType = 0
				else:
					tileInstance.tileType = 3
				var roll = rng.randf()
				if roll < 0.15:
					tileInstance.orb = 1
				elif roll < 0.2:
					tileInstance.orb = 2
			elif row == 1 or row == 6 or col == 1 or col == 6:
				if rng.randf() < 0.1:
					tileInstance.tileType = 0
				else:
					tileInstance.tileType = 2
			elif row == 2 or row == 5 or col == 2 or col == 5:
				tileInstance.tileType = 2
			else:
				tileInstance.tileType = 1
			
			self.player_moved.connect(tileInstance._on_player_moved)
			end_turn.connect(tileInstance._on_end_turn)
			run_buffers.connect(tileInstance._on_run_buffers)
			add_child.call_deferred(tileInstance)
			tile_array.append(tileInstance)
	_on_window_resized()

	for i in len(tile_array):
		var up_index = i - 1
		var down_index = i + 1
		var left_index = i - GRID_WIDTH
		var right_index = i + GRID_WIDTH
		if up_index >= 0 && (up_index / GRID_WIDTH == i / GRID_WIDTH):
			tile_array[i].TILE_UP = tile_array[up_index]
		if left_index >= 0:
			tile_array[i].TILE_LEFT = tile_array[left_index]
		if right_index < len(tile_array):
			tile_array[i].TILE_RIGHT = tile_array[right_index]
		if down_index < len(tile_array) && (down_index / GRID_WIDTH == i / GRID_WIDTH):
			tile_array[i].TILE_DOWN = tile_array[down_index]

	#Populate enemy buffer
	trigger_wave()
		

func _on_enemy_death():
	enemy_count -= 1
	$CanvasLayer/Remaining.text = "Enemies: " + str(enemy_count)
	if enemy_count == 0:
		trigger_wave()

func trigger_wave():
	SfxPlayer.play_sound_effect_from_library("spawn")
	var rng = RandomNumberGenerator.new()
	wave += 1
	
	if wave == 4:
		get_tree().change_scene_to_file("res://Scenes/end.tscn")
	
	for i in enemies[wave - 1]:
		enemy_load_buffer.append(rng.randi_range(0, 23))
	$"CanvasLayer/Wave Title".visible = true
	match wave:
		1:
			$"CanvasLayer/Wave Title".text = "Wave One"
			$"CanvasLayer/StageIndicator".text = "Wave 1 of 3"
		2:
			$"CanvasLayer/Wave Title".text = "Wave Two"
			$"CanvasLayer/StageIndicator".text = "Wave 2 of 3"
		3:
			$"CanvasLayer/Wave Title".text = "Wave Three"
			$"CanvasLayer/StageIndicator".text = "Wave 3 of 3"
	$"CanvasLayer/Wave Title/Timer".start()

func spawn_enemies():
	var next_buf: Array[int] = []
	
	var enemy_types = Constants.EnemyType.values()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	while !enemy_load_buffer.is_empty():
		var index = enemy_load_buffer.pop_back()
		var pos = tile_map[index]
		var tile_index = pos.x * 8 + pos.y
		var type = enemy_types.pick_random()
		var res = tile_array[tile_index].add_enemy(type, 0)
		if res == false:
			next_buf.append(index)
		else:
			enemy_count += 1
	enemy_load_buffer = next_buf
	$CanvasLayer/Remaining.text = "Enemies: " + str(enemy_count)

func _get_hovered_tile() -> Vector2:
	var mouse_pos = get_viewport().get_mouse_position()
	var visible_rect_dim = get_viewport().get_visible_rect().size
	var mouse_x = mouse_pos.x - (visible_rect_dim.x / 2)
	var mouse_y = mouse_pos.y - (visible_rect_dim.y / 2)
	if sigil.player_on:
		if mouse_x > 0 && mouse_y > 0:
			return Vector2(4, 4)
		elif mouse_x < 0 && mouse_y < 0:
			return Vector2(3, 3)
		elif mouse_x > 0 && mouse_y < 0:
			return Vector2(4, 3)
		elif mouse_x < 0 && mouse_y > 0:
			return Vector2(3, 4)
		return Vector2(-1, -1)
	else:
		if abs(mouse_x) < 64 && mouse_y > 0:
			# Top Middle
			return Vector2(player_pos[0], player_pos[1] + 1)
		elif abs(mouse_x) < 64 && mouse_y < 0:
			# Bottom Middle
			return Vector2(player_pos[0], player_pos[1] - 1)
		elif mouse_x > 0 && abs(mouse_y) < 64:
			# Right middle
			return Vector2(player_pos[0] + 1, player_pos[1])
		elif mouse_x < 0 && abs(mouse_y) < 64:
			# Left middle
			return Vector2(player_pos[0] - 1, player_pos[1])
		elif mouse_x < 0 && mouse_y < 0:
			# Bottom left
			return Vector2(player_pos[0] - 1, player_pos[1] - 1)
		elif mouse_x > 0 && mouse_y < 0:
			# Bottom right
			return Vector2(player_pos[0] + 1, player_pos[1] - 1)
		elif mouse_x > 0 && mouse_y > 0:
			# Top Right
			return Vector2(player_pos[0] + 1, player_pos[1] + 1)
		else:
			# Top left
			return Vector2(player_pos[0] - 1, player_pos[1] + 1)

func get_neighboring_tiles(player_pos: Vector2i, grid_width: int, tile_array: Array) -> Array:
	var neighbors = []
	var x = player_pos.x
	var y = player_pos.y
	
	# Directions in clockwise order starting from top-left
	var offsets = [
		Vector2i(-1, -1), # 0 Top-Left
		Vector2i(0, -1),  # 1 Top
		Vector2i(1, -1),  # 2 Top-Right
		Vector2i(1, 0),   # 3 Right
		Vector2i(1, 1),   # 4 Bottom-Right
		Vector2i(0, 1),   # 5 Bottom
		Vector2i(-1, 1),  # 6 Bottom-Left
		Vector2i(-1, 0),  # 7 Left
	]
	
	for offset in offsets:
		var nx = x + offset.x
		var ny = y + offset.y
		if nx >= 0 and nx < grid_width and ny >= 0 and ny < grid_width:
			var index = nx * grid_width + ny
			neighbors.append(tile_array[index])
		else:
			neighbors.append(null) # Out of bounds
	
	return neighbors

func _process(delta: float) -> void:
	for tile in tile_array:
		tile._mouse_exited()
	
	if Playervariables.class_ability:
		Playervariables.class_ability = false
		player.AP += 10
		player.health += 3
		player.curse -= 5
		dmg_mul = 1.5
		healthbar.set_health(player.health, false)
		cursebar.set_health_with_timer(player.curse)
		actionbar.set_health_with_timer(player.AP)
	
	if Playervariables.weapon_ability && !sigil.player_on:
		if !player.ap_check(3):
			Playervariables.weapon_ability = false
			Playervariables.weapon_cooldown = 0
			
		var mouse_pos = get_viewport().get_mouse_position()
		var visible_rect_dim = get_viewport().get_visible_rect().size
		var mouse_x = mouse_pos.x - (visible_rect_dim.x / 2)
		var mouse_y = mouse_pos.y - (visible_rect_dim.y / 2)
		var tile_1: Tile
		var tile_2: Tile
		var tile_3: Tile
		var neighbours = get_neighboring_tiles(Vector2i(player_pos[0], player_pos[1]), GRID_WIDTH, tile_array)
		if abs(mouse_x) > abs(mouse_y) && mouse_x > 0:
			# Right
			tile_1 = neighbours[2]
			tile_2 = neighbours[3]
			tile_3 = neighbours[4]
		elif abs(mouse_x) > abs(mouse_y) && mouse_x < 0:
			# Left
			tile_1 = neighbours[0]
			tile_2 = neighbours[7]
			tile_3 = neighbours[6]
		elif mouse_y < 0:
			tile_1 = neighbours[0]
			tile_2 = neighbours[1]
			tile_3 = neighbours[2]
		else:
			# Down
			tile_1 = neighbours[4]
			tile_2 = neighbours[5]
			tile_3 = neighbours[6]
		if tile_1:
			tile_1._mouse_entered()
		if tile_2:
			tile_2._mouse_entered()
		if tile_3:
			tile_3._mouse_entered()
		
		if Playervariables.mouse_move:
			Playervariables.weapon_ability = false
			Playervariables.mouse_move = false
			if tile_1:
				_attack_tile(tile_1.tile_pos.x, tile_1.tile_pos.y, false)
			if tile_2:
				_attack_tile(tile_2.tile_pos.x, tile_2.tile_pos.y, false)
			if tile_3:
				_attack_tile(tile_3.tile_pos.x, tile_3.tile_pos.y, false)
			
	
	else:
		if !sigil.mouse_on:
			var coords: Vector2 = _get_hovered_tile()
			var x = coords.x
			var y = coords.y
			
			if Playervariables.move:
				Playervariables.move = false
				Playervariables.mouse_move = false
				match Playervariables.orientation:
					Playervariables.Orientation.UP:
						if int(player.pos.y) % GRID_WIDTH != 0:
							move_player(player.pos.x, player.pos.y - 1)
					Playervariables.Orientation.DOWN:
						if int(player.pos.y) % GRID_WIDTH != GRID_WIDTH - 1:
							move_player(player.pos.x, player.pos.y + 1)
					Playervariables.Orientation.LEFT:
						if int(player.pos.x) % GRID_WIDTH != 0:
							move_player(player.pos.x - 1, player.pos.y)
					Playervariables.Orientation.RIGHT:
						if int(player.pos.x) % GRID_WIDTH != GRID_WIDTH - 1:
							move_player(player.pos.x + 1, player.pos.y)
			
			var index = int(x) * 8 + int(y)
			
			if (x >= 0 && x < 8 && y >= 0 && y < 8):
				tile_array[index]._mouse_entered()
				if Playervariables.mouse_move:
					Playervariables.move = false
					Playervariables.mouse_move = false
					move_player(int(x), int(y))

func _attack_tile(x: int, y: int, use_ap = true):
	if !player.ap_check(4) && use_ap:
		return
	var rng = RandomNumberGenerator.new()
	tile_array[x * GRID_WIDTH + y].damage_enemy(int(rng.randi_range(12, 15) * dmg_mul))
	if use_ap:
		player.AP -= 4
		actionbar.set_health_with_timer(player.AP)

func _set_player(x: int, y: int, AP: int):
	var tween = create_tween()

	if x == -1:
		if !player.ap_check(AP):
			return
		emit_signal("player_moved")
		sigil.set_player(true)
		tween.tween_property(cam, "global_position", Vector2(0, 0), 0.25)
		tween.play()
	else:
		var index = x * GRID_WIDTH + y
		if tile_array[index].enemy_count != 0:
			#move failed
			if player_pos[0] == -1:
				sigil.set_player(true)
			else:
				tile_array[player_pos[0] * GRID_WIDTH + player_pos[1]].set_player(true)
			_attack_tile(x, y)
			return
		if !player.ap_check(AP):
			return
		emit_signal("player_moved")
		tile_array[index].set_player(true)
		tween.tween_property(cam, "global_position", tile_array[index].global_position, 0.25)
		tween.play()
	player_pos[0] = x
	player_pos[1] = y
	player.AP -= AP
	actionbar.set_health_with_timer(actionbar.health - AP)
	player.moved = true
	Playervariables.mouse_move = false
	Playervariables.move = false
	player.pos = Vector2(x, y)
	SfxPlayer.play_sound_effect_from_library("move")

func move_player(x: int, y: int):
	var dx = abs(x - player_pos[0])
	var dy = abs(y - player_pos[1])
	if x == -1:
		if (player_pos[0] == 3 and player_pos[1] == 3) or (player_pos[0] == 4 and player_pos[1] == 3) or (player_pos[0] == 3 and player_pos[1] == 4) or (player_pos[0] == 4 and player_pos[1] == 4):
			_set_player(x, y, 2)
		return
	if player_pos[0] == -1:
		# on sigil circle
		if (x == 3 and y == 3) or (x == 4 and y == 3) or (x == 3 and y == 4) or (x == 4 and y == 4):
			_set_player(x, y, 2)
		return
	if (dx > 1 or dy > 1):
		return
	if (dx == 0 and dy == 0):
		return
	if (dx == 1 and dy == 1):
		_set_player(x, y, 5)
	else:
		_set_player(x, y, 2)

func _on_window_resized():
	var viewport_height = get_viewport().get_visible_rect().size.y
	var grid_height = TILE_SCALE * 64 * 10
	var zoom_y = viewport_height / grid_height
	zoom_y *= 2.25
	cam.zoom = Vector2(zoom_y, zoom_y)

func _on_endturnbutton_endturn() -> void:
	emit_signal("end_turn", player.pos)
	var index: int = int(player.pos.x) * GRID_WIDTH + int(player.pos.y)
	
	dmg_mul = 1.0
	
	if player.curse >= 20:
		SfxPlayer.play_sound_effect_from_library("purify")
		player.health -= player.corruption
		player.corruption = 0
		healthbar.set_health(player.health, true)
		if player.health <= 0:
			_game_over()
	
	if int(player.pos.x == -1):
		# sigil tile
		player.cursed = true
		player.curse += 1
	else:
		match tile_array[index].tileType:
			0:
				player.curse -= 3
			1:
				player.cursed = true
				player.curse += 2
			2:
				player.cursed = true
				player.curse += 4
			3:
				player.cursed = true
				player.curse += 7
	
	player.end_turn()
	
	cursebar.set_health_with_timer(player.curse)
	corruptioncounter.set_value(player.corruption)
	actionbar.set_health_with_timer(player.AP)
	spawn_enemies()
	emit_signal("run_buffers")

func _game_over():
	SfxPlayer.play_sound_effect_from_library("death")
	if get_tree():
		get_tree().change_scene_to_file("res://Scenes/gameover.tscn")


func _on_damage(dmg: int):
	DamageNumbers.display_number(dmg, cam.global_position, false)
	player.damage(dmg)
	healthbar.set_health(player.health)
	if player.health <= 0:
		_game_over()
	
