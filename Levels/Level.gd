class_name TileMapLevel
#tool
extends TileMap

signal level_initialised
signal all_crate_moves_finished
signal all_level_goals_completed(move_count,stars)

enum TileID{
	TILE_VOID = 3,
	TILE_WALL = 6,
	TILE_FLOOR = 7,
	}

export var tile_set_floor_color:Color setget set_tile_set_floor_color
export var star_requirements = {"flawless":0,"3 star":0,"2 star":0,"1 star":0}

var tiles = {}
var objects = {}

var move_count:int
var stars:int = 4
var _err

func set_tile_set_floor_color(new_color):
	tile_set_floor_color = new_color
	tile_set.tile_set_modulate(TileID.TILE_WALL,tile_set_floor_color)

func _ready():
	tile_set.tile_set_modulate(TileID.TILE_WALL,Color(1,1,1,0))
	get_tree().call_group("UI","update_level_name")
	initialise_move_count()
	detect_tile_positions()
	detect_objects()
	connect_object_signals()
	connect_main_signals()
	emit_signal("level_initialised")

func check_crate_moves_finished():
	for crate in objects.Crate:
		if crate.is_moving:
			return
	#print("all_crate_moves_finished")
	emit_signal("all_crate_moves_finished")

func check_level_goals_completed():
	for goal in objects.Goal:
		if not goal.is_complete:
			return
	#print("all_level_goals_completed")
	emit_signal("all_level_goals_completed",move_count,stars)
	SaveData.updateLevelStars(LevelData.current_level,stars)

func detect_objects():
	objects = { "Crate":[], "ButtonFloor":[], "Door":[], "Goal":[], "LaunchPad":[] }
	for object in get_children():
		if not objects.has(object.get_class()):
			objects[object.get_class()] = []
		objects[object.get_class()].append(object)
		object.snap_to_tile()
	print("objects = ",objects)

func detect_tile_positions():
	tiles = {}
	tiles[TileID.TILE_VOID] = {
		"class":"Void",
		"positions":get_tilemap_positions(TileID.TILE_VOID)
		}
	tiles[TileID.TILE_FLOOR] = {
		"class":"Floor",
		"positions":get_tilemap_positions(TileID.TILE_FLOOR)
		}
	tiles[TileID.TILE_WALL] = {
		"class":"Wall",
		"positions":get_tilemap_positions(TileID.TILE_WALL)
		}
	#print("tiles = ",tiles)

func connect_object_signals():
	# Crate signals
	for crate_from in objects.Crate:
		_err = connect("level_initialised",crate_from,"set_is_interactable",[true])
		# Letting other crates know when we've started moving
		for crate_to in objects.Crate:
			crate_from.connect("crate_move_started",crate_to,"set_is_interactable",[false])
		# Letting buttons know when we've moved on/off of them
		for button_floor in objects.ButtonFloor:
			if crate_from.speed_mode == Crate.SpeedMode.SLOW:
				crate_from.connect("crate_step_finished",button_floor,"update_off")
			crate_from.connect("crate_move_stopped",button_floor,"update_on_or_off")
		# Letting goals know when we could be on them
		for goal in objects.Goal:
			crate_from.connect("crate_step_finished",goal,"try_to_complete")
		crate_from.connect("crate_move_finished",self,"check_crate_moves_finished")
		crate_from.connect("crate_move_inputted",self,"increment_move_count")
		_err = connect("all_crate_moves_finished",crate_from,"set_is_interactable",[true])
	# Button signals
	for button_floor in objects.ButtonFloor:
		_err = connect("level_initialised",button_floor,"update_on_or_off",[false])
		for door in objects.Door:
			if button_floor.signal_id == door.signal_id:
				button_floor.connect("button_pressed",door,"open_door")
				button_floor.connect("button_released",door,"close_door")
	# Goal signals
	for goal in objects.Goal:
		_err = connect("level_initialised",goal,"try_to_complete")
		goal.connect("level_goal_completed",self,"check_level_goals_completed")

func connect_main_signals():
	if not get_parent():
		return
	_err = connect("all_level_goals_completed",get_parent().get_node("../LevelUI"),"complete_level",[],CONNECT_ONESHOT)

# reset move_count
func initialise_move_count():
	move_count = 0
	update_current_stars()
	get_tree().call_group("UI","update_move_count",move_count)
	get_tree().call_group("UI","update_stars",stars)

# increment move_count
func increment_move_count():
	move_count += 1
	update_current_stars()
	get_tree().call_group("UI","update_move_count",move_count)
	get_tree().call_group("UI","update_stars",stars)

func update_current_stars():
	if move_count <= star_requirements["flawless"]:
		stars = 4
	elif move_count <= star_requirements["3 star"]:
		stars = 3
	elif move_count <= star_requirements["2 star"]:
		stars = 2
	elif move_count <= star_requirements["1 star"]:
		stars = 1
	else:
		stars = 0

func get_tile_map_rect() -> Rect2:
	var tile_vector_array = get_used_cells()
	var x = {"left":tile_vector_array[0].x,	"right":tile_vector_array[0].x}
	var y = {"top":tile_vector_array[0].y,	"bottom":tile_vector_array[0].y}
	for tile_vector in get_used_cells():
		# x checks
		if tile_vector.x < x.left:
			x.left = tile_vector.x
		elif tile_vector.x > x.right:
			x.right = tile_vector.x
		# y checks
		if tile_vector.y < y.top:
			y.top = tile_vector.y
		elif tile_vector.y > y.bottom:
			y.bottom = tile_vector.y
	
	# Convert to Rect2
	var start_vector = Vector2(x.left,y.top) * cell_size
	var end_vector = Vector2(x.right+1,y.bottom+1) * cell_size
	var size = end_vector - start_vector
	
	return Rect2(start_vector,size)

func get_tilemap_positions(tile_id) -> Array:
	var tile_coord_array = get_used_cells_by_id(tile_id)
	var tile_position_array = []
	for tile_coord in tile_coord_array:
		tile_position_array.append((tile_coord + 0.5 * Vector2.ONE) * cell_size)
	return tile_position_array

func get_tile_positions(tile_id):
	return tiles[tile_id].positions
