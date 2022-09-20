extends Node2D

onready var transition = $UI/Transition
onready var tilemap = $WorldMap
onready var player = $Player

var _tile_creator_timer = null
var _last_tile_pos = Vector2(69, 19)
var _tile_array_vector2ds = []

func _ready():
	Global.text_box = ""
	calculate_switch_blocks()
	var _error = Global.connect("blocks_switched",self,"calculate_switch_blocks")
	transition.open()
	
	var id = tilemap.tile_set.get_tiles_ids()[-1]
	var tiles = tilemap.tile_set
	var rect = tilemap.tile_set.tile_get_region(id)
	var size_x = rect.size.x / tiles.autotile_get_size(id).x
	var size_y = rect.size.y / tiles.autotile_get_size(id).y
	for x in range(size_x):
		for y in range(size_y):
			var priority = tiles.autotile_get_subtile_priority(id, Vector2(x, y))
			for p in priority:
				_tile_array_vector2ds.append(Vector2(x, y))
	
	_tile_creator_timer = Timer.new()
	add_child(_tile_creator_timer)
	_tile_creator_timer.connect("timeout", self, "_on_Timer_timeout")
	_tile_creator_timer.set_wait_time(0.03)
	_tile_creator_timer.set_one_shot(false) # Make sure it loops
	_tile_creator_timer.start()

	
func add_random_ground_tile():
	var random_tile_vec2d = _tile_array_vector2ds[rand_range(0, _tile_array_vector2ds.size())]
	var new_pos = Vector2(_last_tile_pos.x + 1, _last_tile_pos.y)
	var id = tilemap.tile_set.get_tiles_ids()[-1]
	tilemap.set_cell(new_pos.x, new_pos.y, id, false, false, false, random_tile_vec2d)
	print("Placed random ground tile at %s " % new_pos)
	_last_tile_pos = new_pos

func _on_Timer_timeout():
	add_random_ground_tile()

func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause"):
		var _error = get_tree().change_scene("res://UI/Menu.tscn")
		
func calculate_switch_blocks():
	if Global.block_switch:
		#4 to 2
		for b in tilemap.get_used_cells_by_id(4):
			tilemap.set_cellv(b,2)
		#3 to 5
		for b in tilemap.get_used_cells_by_id(3):
			tilemap.set_cellv(b,5)
	else:
		#2 to 4
		for b in tilemap.get_used_cells_by_id(2):
			tilemap.set_cellv(b,4)
		#5 to 3
		for b in tilemap.get_used_cells_by_id(5):
			tilemap.set_cellv(b,3)
