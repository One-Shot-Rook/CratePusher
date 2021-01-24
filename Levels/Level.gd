#tool
extends TileMap

signal all_crate_moves_finished
signal all_level_goals_completed(move_count,stars)

var objects = {}

var move_count:int
var stars:int = 4

export var tile_set_floor_color:Color setget set_tile_set_floor_color
export var star_requirements = {"flawless":0,"3 star":0,"2 star":0,"1 star":0}

func set_tile_set_floor_color(new_color):
	tile_set_floor_color = new_color
	tile_set.tile_set_modulate(tile_set.get_tiles_ids()[2],tile_set_floor_color)

func _ready():
	tile_set.tile_set_modulate(tile_set.get_tiles_ids()[1],Color(1,1,1,0))
	get_tree().call_group("UI","update_level_name")
	initialise_move_count()
	detect_objects()
	connect_object_signals()
	connect_main_signals()

func check_crate_moves_finished():
	for crate in objects.Crate:
		if crate.is_moving:
			return
	#print("all_crate_moves_finished")
	emit_signal("all_crate_moves_finished")

func check_level_goals_completed():
	for button_floor in objects.ButtonFloor:
		if button_floor.is_level_goal and not button_floor.is_pressed:
			return
	#print("all_level_goals_completed")
	emit_signal("all_level_goals_completed")

func detect_objects():
	objects = {}
	for object in get_children():
		if not objects.has(object.get_class()):
			objects[object.get_class()] = []
		objects[object.get_class()].append(object)
	print("objects = ",objects)

func connect_object_signals():
	# Crate signals
	for crate_from in objects.Crate:
		# Disabling interactables
		for crate_to in objects.Crate:
			crate_from.connect("crate_move_inputted",crate_to,"set_is_interactable",[false])
		# Letting buttons know when we've moved on/off of them
		for button_floor in objects.ButtonFloor:
			if crate_from.speed_mode == Crate.SpeedMode.SLOW:
				crate_from.connect("crate_step_finished",button_floor,"update_on_or_off",[true])
			crate_from.connect("crate_move_finished",button_floor,"update_on_or_off")
		crate_from.connect("crate_move_finished",self,"check_crate_moves_finished")
		crate_from.connect("crate_move_inputted",self,"increment_move_count")
		connect("all_crate_moves_finished",crate_from,"set_is_interactable",[true])
	# Button signals
	for button_floor in objects.ButtonFloor:
		if button_floor.is_level_goal:
			button_floor.connect("level_goal_completed",self,"check_level_goals_completed")
			continue
		for door in objects.Door:
			if button_floor.signal_id == door.signal_id:
				button_floor.connect("button_pressed",door,"update_open_or_closed")
				button_floor.connect("button_released",door,"update_open_or_closed")

func connect_main_signals():
	if not get_parent():
		return
	connect("all_level_goals_completed",get_parent().get_node("../LevelUI"),"complete_level",[move_count,stars],CONNECT_ONESHOT)
	connect("all_level_goals_completed",SaveData,"updateLevelStars",[LevelData.current_level,stars],CONNECT_ONESHOT)

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


