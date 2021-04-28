class_name GameLevel
tool
extends TileMap

signal initial_react
signal level_initialised
signal all_crate_moves_finished
signal all_level_goals_completed(move_count,stars)

enum TileID{
	TILE_VOID = 3,
	TILE_FLOOR = 14,
	TILE_WALL = 9,
	}

export var hint_text:String = ""
export var star_requirements = {"flawless":16,"3 star":19,"2 star":22,"1 star":25}

var testing_mode:bool = false
var animate:bool = true

var dir = [Vector2.UP,Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]

var level_name:String
var timeline = []
var timeline_index = -1
var tiles := {}
var objects := {}

var signal_buses = {}
var is_level_complete := false
var move_count:int
var stars:int = 4
var errors

func _init():
	z_index = 0

func _ready():
	if Engine.editor_hint:
		return
	#print()
	#print(" [LEVEL] ",level_name)
	#tile_set.tile_set_modulate(TileID.TILE_WALL,Color(1,1,1,0))
	get_tree().call_group("UI","update_level_name")
	initialise_move_count()
	detect_tile_positions()
	detect_objects()
	#print("  objects = ",objects)
	connect_object_signals()
	connect_main_signals()
	animate = false
	emit_signal("initial_react")
	emit_signal("level_initialised")
	animate = true
	save_level_state()
	GameInput.enable_input_ui(objects.Crate)

func _exit_tree():
	if Engine.editor_hint:
		return
	GameInput.disable_input_ui()

func fill_walls():
	
	var rect = get_used_rect().grow(8)
	var used_tiles = get_used_cells()
	var from = rect.position
	var to = rect.position + rect.size
	
	for x in range(from.x,to.x):
		for y in range(from.y,to.y):
			if not Vector2(x,y) in used_tiles:
				set_cell(x,y,TileID.TILE_WALL)
	
	update_bitmask_region(from,to)
	
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
	#print("  ",timeline_index,":",current_level_state)

func load_level_state(new_timeline_index):
	if is_level_complete:
		return
	timeline_index = new_timeline_index
	var new_level_state = timeline[timeline_index]
	for object in new_level_state:
		object.set_save_data(new_level_state[object])
	set_move_count(timeline_index)
	animate = false
	#emit_signal("level_initialised")
	emit_signal("initial_react")
	animate = true
	#print("  ",timeline_index,":",new_level_state)

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
		if object.name.begins_with("TileMap"):
			continue
		if not objects.has(object.get_class()):
			objects[object.get_class()] = []
		if "Button" in object.get_class():
			if not object.signal_id in signal_buses:
				create_signal_bus(object.signal_id)
		objects[object.get_class()].append(object)
		object.snap_to_tile()
		object.testing_mode = testing_mode
		object.Level = self
	#print(signal_buses)

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
		errors += connect("initial_react",crate_from,"react_to_currently_colliding")
		errors += connect("level_initialised",crate_from,"set_is_interactable",[true])
		# Letting other crates know when we've started moving
		for crate_to in objects.Crate:
			crate_from.connect("crate_move_started",crate_to,"set_is_interactable",[false])
			crate_from.connect("crate_move_stopped",crate_to,"react_to_currently_colliding")
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
		errors += connect("initial_react",button_floor,"update_on_or_off")
		var signal_bus = signal_buses[button_floor.signal_id]
		signal_bus.input_signals += 1
		button_floor.connect("button_pressed",signal_bus,"set_received_signals",[+1])
		button_floor.connect("button_released",signal_bus,"set_received_signals",[-1])
		button_floor.connect("button_changed",signal_bus,"set_received_signals",[+0])
	# Door signals
	for door in objects.Door:
		var signal_bus = signal_buses[door.signal_id]
		match door.open_mode:
			Door.OpenMode.OR:
				signal_bus.connect("OR_update",door,"set_is_open")
			Door.OpenMode.AND:
				signal_bus.connect("AND_update",door,"set_is_open")
#	#SingalBus signals
#	for signal_bus in signal_buses.values():
#		errors += connect("level_initialised",signal_bus,"check_signals")
	# Goal signals
	for goal in objects.Goal:
		errors += connect("initial_react",goal,"try_to_complete")
		goal.connect("level_goal_completed",self,"check_level_goals_completed")
	#print("  signal connection errors (objects): ",errors)

func connect_main_signals():
	errors = 0
	if get_parent().get_class() == "Viewport":
		return
	var LevelUI = get_parent().get_node("../LevelUI")
	errors += connect("all_level_goals_completed",LevelUI,"complete_level",[],CONNECT_ONESHOT)
	var btnUndo:Button = LevelUI.get_node("topBar/HBoxContainer/btnUndo")
	var btnRedo:Button = LevelUI.get_node("topBar/HBoxContainer/btnRedo")
	errors += btnUndo.connect("pressed",self,"undo_timeline",[])
	errors += btnRedo.connect("pressed",self,"redo_timeline",[])
	#print("  signal connection errors (main): ",errors)

func create_signal_bus(signal_id):
	var signal_bus = SignalBus.new()
	signal_bus.signal_id = signal_id
	add_child(signal_bus)
	signal_buses[signal_id] = signal_bus

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

func get_border_positions():
	if Engine.editor_hint:
		return
	var border_positions = PoolVector2Array()
	var wall_tile_positions = get_used_cells_by_id(TileID.TILE_WALL)
	var floor_tile_positions = get_used_cells_by_id(TileID.TILE_FLOOR)
	for tile_position in wall_tile_positions:
		for dir_vector in dir:
			if not tile_position + dir_vector in wall_tile_positions + floor_tile_positions:
				border_positions.append((tile_position+Vector2.ONE/2) * cell_size)
				var col = ColorRect.new()
				col.mouse_filter = Control.MOUSE_FILTER_IGNORE
				col.rect_position = (tile_position+Vector2.ONE/2) * cell_size
				col.margin_left = col.rect_position.x - cell_size.x/2 - 8
				col.margin_right = col.rect_position.x + cell_size.x + 16
				col.margin_top = col.rect_position.y - cell_size.y/2 - 8
				col.margin_bottom = col.rect_position.y + cell_size.y + 16
				col.color = Color("323232")
				add_child(col)
				break

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
