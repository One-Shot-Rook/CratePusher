class_name GameLevel
#tool
extends TileMap

signal level_initialised
signal all_crate_moves_finished
signal all_level_goals_completed(move_count,stars)

enum TileID{
	TILE_VOID = 3,
	TILE_FLOOR = 7,
	TILE_WALL = 9,
	}

export var tile_set_floor_color:Color setget set_tile_set_floor_color
export var star_requirements = {"flawless":0,"3 star":0,"2 star":0,"1 star":0}

var level_name:String
var timeline = []
var timeline_index = -1
var tiles := {}
var objects := {}

var is_level_complete := false
var move_count:int
var stars:int = 4
var errors

func set_tile_set_floor_color(new_color):
	tile_set_floor_color = new_color
	tile_set.tile_set_modulate(TileID.TILE_WALL,tile_set_floor_color)

func _ready():
	print()
	print(" [LEVEL] ",level_name)
	#tile_set.tile_set_modulate(TileID.TILE_WALL,Color(1,1,1,0))
	get_tree().call_group("UI","update_level_name")
	initialise_move_count()
	detect_tile_positions()
	detect_objects()
	print("  objects = ",objects)
	connect_object_signals()
	connect_main_signals()
	emit_signal("level_initialised")
	save_level_state()

func undo_timeline():
	if timeline_index == 0:
		return
	load_level_state(timeline_index-1)

func redo_timeline():
	if timeline_index == timeline.size() - 1:
		return
	load_level_state(timeline_index+1)
	get_tree().call_group("UI","update_move_count")

func save_level_state(): # Adds the current state to the timeline
	var current_level_state = {}
	for object_array in objects.values():
		for object in object_array:
			current_level_state[object] = object.get_save_data()
	timeline = timeline.slice(0,timeline_index) # Destroy future
	timeline.append(current_level_state)
	timeline_index += 1
	print("  ",timeline_index,":",current_level_state)

func load_level_state(new_timeline_index):
	if is_level_complete:
		return
	timeline_index = new_timeline_index
	var new_level_state = timeline[timeline_index]
	for object in new_level_state:
		object.set_save_data(new_level_state[object])
	set_move_count(timeline_index)
	emit_signal("level_initialised")
	#emit_signal("all_crate_moves_finished")
	print("  ",timeline_index,":",new_level_state)

func check_crate_moves_finished():
	for crate in objects.Crate:
		if crate.is_moving:
			return
	#print("all_crate_moves_finished")
	save_level_state()
	emit_signal("all_crate_moves_finished")

func check_level_goals_completed():
	for goal in objects.Goal:
		if not goal.is_complete:
			return
	#print("all_level_goals_completed")
	emit_signal("all_level_goals_completed",move_count,stars)
	SaveData.updateLevelStars(LevelData.current_level,stars)
	is_level_complete = true

func detect_objects():
	objects = { "Crate":[], "ButtonFloor":[], "Door":[], "Goal":[], "LaunchPad":[] }
	for object in get_children():
		if not objects.has(object.get_class()):
			objects[object.get_class()] = []
		objects[object.get_class()].append(object)
		object.snap_to_tile()
		object.Level = self

func get_objects_by_class(object_class:String):
	var object_array = []
	for object in objects[object_class]:
		if object.is_detectable:
			object_array.append(object)
	return object_array

func get_object_array():
	var object_array = []
	for object_class in objects:
		object_array += get_objects_by_class(object_class)
	return object_array

func add_object(object):
	var object_class = object.get_class()
	if objects.has(object_class):
		objects[object_class].append(object)

func remove_object(object):
	var object_class = object.get_class()
	if objects.has(object_class):
		objects[object_class].erase(object)

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
	errors = 0
	# Crate signals
	for crate_from in objects.Crate:
		errors += connect("level_initialised",crate_from,"react_to_currently_colliding")
		errors += connect("level_initialised",crate_from,"set_is_interactable",[true])
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
		errors += connect("all_crate_moves_finished",crate_from,"set_is_interactable",[true])
	# Button signals
	for button_floor in objects.ButtonFloor:
		errors += connect("level_initialised",button_floor,"update_on_or_off",[false])
		for door in objects.Door:
			if button_floor.signal_id == door.signal_id:
				button_floor.connect("button_pressed",door,"open_door")
				button_floor.connect("button_released",door,"close_door")
	# Goal signals
	for goal in objects.Goal:
		errors += connect("level_initialised",goal,"try_to_complete")
		goal.connect("level_goal_completed",self,"check_level_goals_completed")
	print("  signal connection errors (objects): ",errors)

func connect_main_signals():
	errors = 0
	if not get_parent():
		return
	var LevelUI = get_parent().get_node("../LevelUI")
	errors += connect("all_level_goals_completed",LevelUI,"complete_level",[],CONNECT_ONESHOT)
	var btnUndo:Button = LevelUI.get_node("topBar/HBoxContainer/btnUndo")
	var btnRedo:Button = LevelUI.get_node("topBar/HBoxContainer/btnRedo")
	errors += btnUndo.connect("pressed",self,"undo_timeline",[])
	errors += btnRedo.connect("pressed",self,"redo_timeline",[])
	print("  signal connection errors (main): ",errors)

# reset move_count
func initialise_move_count():
	set_move_count(0)

# increment move_count
func increment_move_count():
	set_move_count(move_count + 1)

func set_move_count(new_value):
	move_count = new_value
	get_tree().call_group("UI","update_move_count",move_count)
	update_current_stars()

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
	get_tree().call_group("UI","update_stars",stars)

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

func get_tilemap_positions(tile_id) -> PoolVector2Array:
	var tile_coord_array = get_used_cells_by_id(tile_id)
	var tile_position_array = []
	for tile_coord in tile_coord_array:
		tile_position_array.append((tile_coord + 0.5 * Vector2.ONE) * cell_size)
	return tile_position_array

func get_tile_positions(tile_id):
	return tiles[tile_id].positions

func _unhandled_key_input(event):
	
	if is_level_complete:
		return
	
	if event.is_action_pressed("undo"):
		undo_timeline()
	
	elif event.is_action_pressed("redo"):
		redo_timeline()
