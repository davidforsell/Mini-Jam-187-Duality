extends Node2D

@onready var tile = preload("res://Scenes/tile.tscn")
@onready var cam = $Camera2D
@onready var sigil = $SigilCircle
@onready var cursebar = $CanvasLayer/Cursebar
@onready var actionbar = $CanvasLayer/Actionbar

signal player_moved
signal end_turn(player_pos: Vector2)
signal run_buffers

var TILE_SCALE = 2.0
var tile_array: Array[Tile] = []
var player_pos: Array[int] = [-1, -1]
var enemy_load_buffer: Array[int] = []

var player = Player.new(Vector2(-1, -1))

var tile_map = {
	0: Vector2(0, 0),
	1: Vector2(1, 0),
	2: Vector2(2, 0),
	3: Vector2(3, 0),
	4: Vector2(4, 0),
	5: Vector2(5, 0),
	6: Vector2(5, 1),
	7: Vector2(5, 2),
	8: Vector2(5, 3),
	9: Vector2(5, 4),
	10: Vector2(5, 5),
	11: Vector2(4, 5),
	12: Vector2(3, 5),
	13: Vector2(2, 5),
	14: Vector2(1, 5),
	15: Vector2(0, 5), 
	16: Vector2(0, 4),
	17: Vector2(0, 3),
	18: Vector2(0, 2),
	19: Vector2(0, 1)
}

func _ready() -> void:
	get_tree().root.size_changed.connect(self._on_window_resized)
	
	self.player_moved.connect(sigil._on_player_moved)
	
	actionbar.init_health(20)
	cursebar.init_health(20)
	cursebar.set_health(0)
	
	# Load tiles
	for row in 6:
		for col in 6:
			var sigval = -1
			if row == 2 and col == 2:
				sigval = 2
			elif row == 3 and col == 2:
				sigval = 3
			elif row == 2 and col == 3:
				sigval = 0
			elif row == 3 and col == 3:
				sigval = 1
			var coords = Vector2(row * 64 * TILE_SCALE - 2.5 * 64 * TILE_SCALE, col * 64 * TILE_SCALE - 2.5 * 64 * TILE_SCALE)
			var tileInstance: Sprite2D = tile.instantiate()
			tileInstance.global_position = coords
			tileInstance.tile_pos = Vector2(col, row)
			tileInstance.scale = Vector2(TILE_SCALE, TILE_SCALE)
			tileInstance.sigil_neighbour = sigval
			self.player_moved.connect(tileInstance._on_player_moved)
			end_turn.connect(tileInstance._on_end_turn)
			run_buffers.connect(tileInstance._on_run_buffers)
			add_child.call_deferred(tileInstance)
			tile_array.append(tileInstance)
	_on_window_resized()

	for i in len(tile_array):
		var up_index = i - 6
		var down_index = i + 6
		var left_index = i - 1
		var right_index = i + 1
		if up_index >= 0:
			tile_array[i].TILE_UP = tile_array[up_index]
		if left_index >= 0:
			tile_array[i].TILE_LEFT = tile_array[left_index]
		if right_index < len(tile_array):
			tile_array[i].TILE_RIGHT = tile_array[right_index]
		if down_index < len(tile_array):
			tile_array[i].TILE_DOWN = tile_array[down_index]

	#Populate enemy buffer
	var rng = RandomNumberGenerator.new()
	for i in 10:
		enemy_load_buffer.append(rng.randi_range(0, 19))

func spawn_enemies():
	var next_buf: Array[int] = []
	while !enemy_load_buffer.is_empty():
		var index = enemy_load_buffer.pop_back()
		var pos = tile_map[index]
		var tile_index = pos.x * 6 + pos.y
		var res = tile_array[tile_index].add_enemy()
		if res == false:
			next_buf.append(index)
	enemy_load_buffer = next_buf

func _get_hovered_tile() -> Vector2:
	var mouse_pos = get_viewport().get_mouse_position()
	var visible_rect_dim = get_viewport().get_visible_rect().size
	var grid_size = visible_rect_dim.y * 6/8
	var grid_pos_x = (visible_rect_dim.x - grid_size) / 2
	var grid_x = 6 * (mouse_pos.x - grid_pos_x) / grid_size
	var grid_y = (6 * mouse_pos.y / grid_size) - 1
	return Vector2(grid_x, grid_y)

func _process(delta: float) -> void:
	for tile in tile_array:
		tile._mouse_exited()
	if !sigil.mouse_on:
		var coords: Vector2 = _get_hovered_tile()
		var x = coords.x
		var y = coords.y
		if (x >= 0 && x < 6 && y >= 0 && y < 6):
			var index = int(x) * 6 + int(y)
			tile_array[index]._mouse_entered()
			if Input.is_mouse_button_pressed(1):
				move_player(int(x), int(y))

func move_player(x: int, y: int):
	var dx = abs(x - player_pos[0])
	var dy = abs(y - player_pos[1])
	if x == -1:
		if (player_pos[0] == 2 and player_pos[1] == 2) or (player_pos[0] == 3 and player_pos[1] == 2) or (player_pos[0] == 2 and player_pos[1] == 3) or (player_pos[0] == 3 and player_pos[1] == 3):
			player_pos[0] = -1
			player_pos[1] = -1
			emit_signal("player_moved")
			sigil.set_player(true)
			actionbar.set_health_with_timer(actionbar.health - 2)
			player.AP -= 2
			player.moved = true
			player.pos = Vector2(x, y)
		return
	if player_pos[0] == -1:
		# on sigil circle
		if (x == 2 and y == 2) or (x == 3 and y == 2) or (x == 2 and y == 3) or (x == 3 and y == 3):
			emit_signal("player_moved")
			var index = x * 6 + y
			tile_array[index].set_player(true)
			player_pos[0] = x
			player_pos[1] = y
			actionbar.set_health_with_timer(actionbar.health - 2)
			player.AP -= 2
			player.moved = true
			player.pos = Vector2(x, y)
		return
	if (dx > 1 or dy > 1):
		return
	if (dx == 0 and dy == 0):
		return
	emit_signal("player_moved")
	var index = x * 6 + y
	player_pos[0] = x
	player_pos[1] = y
	if (dx == 1 and dy == 1):
		actionbar.set_health_with_timer(actionbar.health - 5)
		player.AP -= 5
		player.moved = true
		player.pos = Vector2(x, y)
	else:
		actionbar.set_health_with_timer(actionbar.health - 2)
		player.AP -= 2
		player.moved = true
		player.pos = Vector2(x, y)
	tile_array[index].set_player(true)

func _on_window_resized():
	var viewport_height = get_viewport().get_visible_rect().size.y
	var grid_height = TILE_SCALE * 64 * 8
	var zoom_y = viewport_height / grid_height
	cam.zoom = Vector2(zoom_y, zoom_y)

func _on_endturnbutton_endturn() -> void:
	emit_signal("end_turn", player.pos)
	player.end_turn()
	actionbar.set_health(player.AP)
	spawn_enemies()
	emit_signal("run_buffers")
