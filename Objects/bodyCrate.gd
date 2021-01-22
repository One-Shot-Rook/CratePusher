class_name Crate, "res://icons/Crate.svg"
#tool
extends KinematicBody2D

enum CrateType{WOODEN,RED,BLUE,PURPLE}
enum SpeedMode{SLOW,FAST}
enum WeightMode{LIGHT,MEDIUM,HEAVY}

export(CrateType) var crate_type = CrateType.WOODEN setget set_crate_type, get_crate_type

var weight_id:int = WeightMode.MEDIUM
var speed_mode:int = SpeedMode.SLOW
var is_movable := false
var snap := false setget snap_to_tile

var tile_size:float = 96
var rng := RandomNumberGenerator.new()

var is_mouse_pressed := false

var is_moving := false
var should_stop_moving := false
var move_direction:Vector2
var move_to_position:Vector2
var move_time := 0.04				# In seconds
var move_distance := 0				# In tiles
var move_distance_standard := 9999	# In tiles
var MOVE_DISTANCE_MAX := 9999		# In tiles

var normal_pitch_scale := 1.0

var COLLISION_RADIUS := 32

var directions = {"U":Vector2.UP,"R":Vector2.RIGHT,"D":Vector2.DOWN,"L":Vector2.LEFT}

func _get_property_list() -> Array:
	return [
		{
			name = "Crate",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "crate_type",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Wooden,Red,Blue,Purple",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "snap",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "weight_id",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Light,Medium,Heavy",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "speed_mode",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Slow,Fast",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "is_movable",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "Movement",
			type = TYPE_NIL,
			hint_string = "move_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "move_distance_standard",
			type = TYPE_INT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,9999",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "move_time",
			type = TYPE_REAL,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.01,1",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func set_crate_type(new_crate_type):
	crate_type = new_crate_type
	initialise_crate()
	update_ui()

func get_crate_type() -> int: return crate_type

func set_mouse_pressed(new_is_mouse_pressed):
	is_mouse_pressed = new_is_mouse_pressed
	update_highlight()

func get_class() -> String: return "Crate"


func _ready():
	initialise_crate()
	tile_size = 96
	snap_to_tile()
	if is_movable:
		enable_move_ui()
	else:
		disable_move_ui()
	react_to_currently_colliding()
	update_ui()

func _enter_tree():
	if not Engine.editor_hint:
		return
	#construct_self()

func initialise_crate():
	match crate_type:
		CrateType.WOODEN:
			name = "crate(Wooden)"
			weight_id = WeightMode.LIGHT
			speed_mode = SpeedMode.SLOW
			move_distance_standard = MOVE_DISTANCE_MAX
			move_time = 0.06
			is_movable = false
			normal_pitch_scale = 1.0
		CrateType.RED:
			name = "crate(Red)"
			weight_id = WeightMode.MEDIUM
			speed_mode = SpeedMode.SLOW
			move_distance_standard = MOVE_DISTANCE_MAX
			move_time = 0.06
			is_movable = true
			normal_pitch_scale = 1.0
		CrateType.BLUE:
			name = "crate(Blue)"
			weight_id = WeightMode.LIGHT
			speed_mode = SpeedMode.FAST
			move_distance_standard = MOVE_DISTANCE_MAX
			move_time = 0.04
			is_movable = true
			normal_pitch_scale = 1.5
		CrateType.PURPLE:
			name = "crate(Purple)"
			weight_id = WeightMode.HEAVY
			speed_mode = SpeedMode.SLOW
			move_time = 0.08
			move_distance_standard = 2
			is_movable = true
			normal_pitch_scale = 0.7
	snap_to_tile()

func update_ui():
	$trailParticles.emitting = false
	match crate_type:
		CrateType.WOODEN:
			$sprite.texture = load("res://Assets/Sprites/svg_crate_wooden.svg")
		CrateType.RED:
			$sprite.texture = load("res://Assets/Sprites/svg_crate_red.svg")
		CrateType.BLUE:
			$sprite.texture = load("res://Assets/Sprites/svg_crate_blue.svg")
		CrateType.PURPLE:
			$sprite.texture = load("res://Assets/Sprites/svg_crate_red.svg")
	$sprite.modulate =			Globals.get_crate_color(crate_type)
	$Directions.modulate = 		Globals.get_crate_color(crate_type)
	$trailParticles.modulate = 	Globals.get_crate_color(crate_type)

func update_highlight():
	$sprite.modulate.a = 1 + int(is_mouse_pressed)


func start_moving(new_move_direction:Vector2,new_move_distance=move_distance_standard) -> void:
	move_distance = new_move_distance
	move_direction = new_move_direction
	is_moving = true
	Globals.update_move_ui()
	# Can the crate move in that direction at all
	if _move():
		play_move_sound()

func _move(_object=null, _key=":position") -> bool:
	
	$trailParticles.emitting = true
	$trailParticles.direction = -move_direction
	should_stop_moving = false
	
	snap_to_tile()
	
	if move_distance <= 0:
		should_stop_moving = true
	move_distance -= 1
	
	if speed_mode == SpeedMode.SLOW:
		Globals.update_buttons_off()
	
	# React to what's ahead
	react_to_move_direction()
	
	# React to what we're on
	react_to_currently_colliding()
	
	
	if should_stop_moving:
		$trailParticles.emitting = false
		stop_moving()
	
	if not is_moving:
		return false
	
	
	# Move to next tile
	move_to_position = position + move_direction * tile_size
	$twnMove.interpolate_property(self, "position",
			null, move_to_position, move_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	$twnMove.start()
	
	return true

func stop_moving(_reason="wall"):
	if not is_moving:
		return
	#print(str(name)+" stopped because "+reason)
	is_moving = false
	move_direction = Vector2.ZERO
	move_distance = 0
	Globals.update_move_ui()



func react_to_move_direction():
	var objects_in_move_direction = get_objects_in_move_direction()
	#print("Objects ahead: ",objects_in_move_direction)
	for object in objects_in_move_direction:
		match object.get_class():
			"TileMap":
				should_stop_moving = true
			"Door":
				var door:Door = object
				if not door.is_open:
					should_stop_moving = true
			"Crate":
				var crate:Crate = object
				var push_distance = weight_id-crate.weight_id
				#print("PUSH ",name," ["+str(weight_id)+"|"+str(crate.weight_id)+"]",str(crate.name))
				if push_distance > 0:
					crate.start_moving(move_direction,push_distance)
				should_stop_moving = true
				#print("crate -> "+str(push_distance/48))

func get_objects_in_move_direction() -> Array:
	var objects = []
	var object_array = get_tree().get_nodes_in_group("object")
	for object in object_array:
		if (object.position - (position+move_direction*tile_size)).length() <= COLLISION_RADIUS:
			objects.append(object)
	if objects.empty(): # If there are no objects scan for walls
		var collision_data = move_and_collide(move_direction*tile_size*get_zoom_level(),true,true,true)
		if collision_data:
			objects.append(collision_data.collider)
	return objects



func react_to_currently_colliding():
	var object_currently_colliding = get_object_currently_colliding()
	if object_currently_colliding:
		#print("currently on: ",object_currently_colliding.get_class())
		match object_currently_colliding.get_class():
			"Hole":
				var hole:Hole = object_currently_colliding
				if hole.is_filled:
					continue
				if speed_mode == SpeedMode.FAST and not should_stop_moving:
					continue
				hole.fill_with($sprite.texture.resource_path)
				should_stop_moving = true
				disappear()
				#queue_free()
			"ButtonFloor":
				var button_floor:ButtonFloor = object_currently_colliding
				if button_floor.is_level_goal_complete(self):
					should_stop_moving = true
					disappear()
			"LaunchPad":
				print("LAUNCH")
				var launch_pad:LaunchPad = object_currently_colliding
				move_direction = launch_pad.get_direction_vector()
				move_distance = move_distance_standard
				should_stop_moving = false

func get_object_currently_colliding() -> Node:
	var object_array = get_tree().get_nodes_in_group("object")
	for object in object_array:
		if object == self:
			continue
		if (object.position - position).length() <= COLLISION_RADIUS:
			return object
	return null



func get_objects_adjacent() -> Dictionary:
	var adjacent_objects = {}
	for dirChar in directions:
		var potential_direction = directions[dirChar]
		var collision_data = move_and_collide(potential_direction*tile_size*get_zoom_level(),true,true,true)
		var object = null
		if collision_data: # If something is in that direction
			object = collision_data.collider
			if collision_data.collider.is_in_group("hole"):
				object = null
		adjacent_objects[dirChar] = object
	return adjacent_objects


func get_zoom_level():
	var tile_map = get_parent()
	if tile_map.get_class() == "TileMap":
		var level_node = tile_map.get_parent()
		if level_node.get_class() == "Node2D":
			return level_node.scale.x
	return 1


func disappear():
	is_movable = false
	$sprite.visible = false
	$shape.disabled = true
	remove_from_group("object")

func reappear():
	is_movable = true
	$sprite.visible = true
	$shape.disabled = false
	add_to_group("object")

func has_move_distance() -> bool:
	return (move_distance > 0)

func snap_to_tile(_blank=false) -> void:
	var shifted_position = position - 16*Vector2.ONE
	position = Vector2( stepify(shifted_position[0],tile_size) + tile_size/2 , stepify(shifted_position[1],tile_size) + tile_size/2 )



func enable_move_ui() -> void:
	if not is_movable or LevelData.level_complete:
		return
	var adjacent_objects = get_objects_adjacent()
	for dirChar in adjacent_objects:
		var adjacentNode = adjacent_objects[dirChar]
		get_node("Directions/spr"+dirChar).visible = (adjacentNode == null)
	$Directions.visible = true

func disable_move_ui() -> void:
	$Directions.visible = false



func play_move_sound():
	rng.randomize()
	$audioMove.pitch_scale = normal_pitch_scale + rng.randf_range(-0.2,+0.2)
	$audioMove.play()



func direction_pressed(new_move_direction:Vector2):
	start_moving(new_move_direction)
	LevelData.incrementMoveCount()

func get_nearest_direction(vector:Vector2):
	var nearest_direction = directions["U"]
	for vector_direction in directions.values():
		var direction_distance = (vector_direction-vector).length()
		var nearest_distance = (nearest_direction-vector).length()
		if direction_distance < nearest_distance:
			nearest_direction = vector_direction
	return nearest_direction



func _on_input_event(_viewport, event, _shape_idx):
	
	if not is_movable:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			set_mouse_pressed(event.pressed)


func _on_mouse_exited():
	
	if is_moving:
		return
	
	if is_mouse_pressed:
		
		set_mouse_pressed(false)
		var local_mouse_position = get_local_mouse_position()
		var nearest_direction = get_nearest_direction(local_mouse_position)
		direction_pressed(nearest_direction)



func construct_self():
	
	#Add shape
	var shape = CollisionShape2D.new()
	shape.name = "shape"
	shape.shape = load("res://Assets/Resources/shape_crate.tres")
	add_child(shape)
	
	# Add sprite
	var sprite = Sprite.new()
	shape.name = "sprite"
	add_child(sprite)
	
	# Add audioMove
	var audioMove = AudioStreamPlayer2D.new()
	audioMove.volume_db = -5
	audioMove.bus = "SFX"
	add_child(audioMove)
	
	# Add twnMove
	var twnMove = Tween.new()
	twnMove.connect("tween_completed",self,"_move")
	add_child(twnMove)
	
	initialise_crate()
	
	update_ui()
	








