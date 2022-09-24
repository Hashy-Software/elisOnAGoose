extends Node2D

onready var transition = $UI/Transition
onready var tilemap = $WorldMap
onready var player = $Player
onready var player_sprite = $Player/Sprite
onready var map_generator = $Objects/MapGenerator

var _tile_creator_timer = null
var _last_tile_pos = Vector2(69, 19)
var _tile_array_vector2ds = []

func _ready():
	Global.text_box = ""
	calculate_switch_blocks()
	var _error = Global.connect("blocks_switched",self,"calculate_switch_blocks")
	transition.open()
	_fill_tile_array()

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

func _fill_tile_array():
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

func _add_random_ground_tiles(n_tiles: int):
	var id = tilemap.tile_set.get_tiles_ids()[-1]
	
	for _i in range(n_tiles):
		var random_tile_vec2d = _tile_array_vector2ds[rand_range(0, _tile_array_vector2ds.size())]
		var new_pos = Vector2(_last_tile_pos.x + 1, _last_tile_pos.y)
		#print("Placed random ground tile at %s " % new_pos)
		tilemap.set_cell(new_pos.x, new_pos.y, id, false, false, false, random_tile_vec2d)
		_last_tile_pos = new_pos

func _remove_ground_tiles(n_tiles: int):
	# Start deleting 200 tiles before last
	var start = _last_tile_pos.x - 200
	for x in range(start, start - n_tiles, -1):
		tilemap.set_cell(x, _last_tile_pos.y, -1)

func _on_MapGenerator_body_entered(_collided_body):
	#print("Entered MapGenerator area")
	var tile_amount = 100
	var tile_size = 16
	
	_add_random_ground_tiles(tile_amount)
	#_remove_ground_tiles(tile_amount)
	
	map_generator.position.x += tile_amount * tile_size - 10

func _on_GasGasGas_finished():
	player.time_elapsed = 0
	$GasGasGas.play(0)


func _on_StartPixelExplosion_timeout():
	$Dino/ApplyPixelExplosion.start()
	$Dino/Sprite.visible = true
	$Dino/AnimatedSprite.visible = false


func _on_ApplyPixelExplosion_timeout():
		
	$Dino/Sprite.material.set_shader_param("progress", $Dino/Sprite.material.get_shader_param("progress") + 0.01)
	if $Dino/Sprite.material.get_shader_param("progress") > 1:
		$Dino/ApplyPixelExplosion.stop()
		$Player.speed = 30_000
	elif $Dino/Sprite.material.get_shader_param("progress") > 0.5:
		player.visible = true
		
