class_name Crate, "res://icons/Crate.svg"
tool
extends KinematicBody2D

enum CrateType{WOODEN,RED,BLUE}
enum SpeedMode{SLOW,FAST}
enum WeightMode{LIGHT,MEDIUM,HEAVY}

export(CrateType) var crate_type = CrateType.WOODEN setget set_crate_type, get_crate_type

var weight_id = WeightMode.MEDIUM
var speed_mode = SpeedMode.SLOW
var is_movable:bool = false

var tile_size:float
var rng := RandomNumberGenerator.new()

var is_mouse_pressed := false

var is_moving := false
var should_stop_moving:= false
var move_direction:Vector2
var move_to_position:Vector2
var move_time := 0.04			# In seconds
var move_distance := 0			# In tiles
var MOVE_DISTANCE_MAX := 9999	# In tiles

var normal_pitch_scale := 1.0

var COLLISION_RADIUS := 4

var directions = {"U":Vector2( 0,-1),"R":Vector2(+1, 0),"D":Vector2( 0,+1),"L":Vector2(-1, 0)}

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
			hint_string = "Wooden,Red,Blue",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func set_crate_type(new_crate_type):
	crate_type = new_crate_type
	initialise_crate()

func get_crate_type() -> int: return crate_type

func set_mouse_pressed(new_is_mouse_pressed):
	is_mouse_pressed = new_is_mouse_pressed
	update_highlight()

func get_class() -> String: return "Crate"


func _ready():
	initialise_crate()
	tile_size = 32
	snap_to_tile()
	if is_movable:
		enable_move_ui()
	else:
		disable_move_ui()
	if speed_mode == SpeedMode.SLOW:
		move_time *= 1.5
	react_to_currently_colliding()
	update_ui()

func initialise_crate():
	match crate_type:
		CrateType.WOODEN:
			name = "crate(Wooden)"
			weight_id = WeightMode.LIGHT
			speed_mode = SpeedMode.SLOW
			is_movable = false
			normal_pitch_scale = 1.0
		CrateType.RED:
			name = "crate(Red)"
			weight_id = WeightMode.MEDIUM
			speed_mode = SpeedMode.SLOW
			is_movable = true
			normal_pitch_scale = 1.0
		CrateType.BLUE:
			name = "crate(Blue)"
			weight_id = WeightMode.LIGHT
			speed_mode = SpeedMode.FAST
			is_movable = true
			normal_pitch_scale = 1.5

func update_ui():
	$trailParticles.emitting = false
	match crate_type:
		CrateType.WOODEN:
			$sprite.texture = load("res://Assets/Sprites/img_crate.png")
			$sprite.scale = Vector2.ONE
			$Directions.modulate = Color.beige
			$trailParticles.modulate = Color.beige
		CrateType.RED:
			$sprite.texture = load("res://Assets/Sprites/img_crate_red.png")
			$sprite.scale = Vector2.ONE
			$Directions.modulate = Color.lightcoral
			$trailParticles.modulate = Color.lightcoral
		CrateType.BLUE:
			$sprite.texture = load("res://Assets/Sprites/img_crate_blue.png")
			$sprite.scale = Vector2.ONE * 0.4
			$Directions.modulate = Color.dodgerblue
			$trailParticles.modulate = Color.dodgerblue

func update_highlight():
	$sprite.modulate.a = 1 + int(is_mouse_pressed)


func start_moving(new_move_direction:Vector2,new_move_distance=MOVE_DISTANCE_MAX) -> void:
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
	
	if speed_mode == SpeedMode.SLOW:
		Globals.update_buttons_off()
	
	snap_to_tile()
	
	if move_distance <= 0:
		should_stop_moving = true
	move_distance -= 1
	
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
		var collision_data = move_and_collide(move_direction*tile_size/3,true,true,true)
		if collision_data:
			objects.append(collision_data.collider)
	return objects



func react_to_currently_colliding():
	var object_currently_colliding = get_object_currently_colliding()
	if object_currently_colliding:
		#print("currently on: ",object_currently_colliding.get_class())
		match object_currently_colliding.get_class():
			"Hole":
				if speed_mode == SpeedMode.FAST and is_moving:
					continue
				var hole:Hole = object_currently_colliding
				if hole.is_filled:
					continue
				hole.fill_with($sprite.texture.resource_path)
				should_stop_moving = true
				queue_free()
			"LaunchPad":
				print("LAUNCH")
				var launch_pad:LaunchPad = object_currently_colliding
				move_direction = launch_pad.get_direction_vector()
				move_distance = MOVE_DISTANCE_MAX
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
		var collision_data = move_and_collide(potential_direction*tile_size*3,true,true,true)
		var object = null
		if collision_data: # If something is in that direction
			object = collision_data.collider
			if collision_data.collider.is_in_group("hole"):
				object = null
		adjacent_objects[dirChar] = object
	return adjacent_objects



func has_move_distance() -> bool:
	return (move_distance > 0)

func snap_to_tile() -> void:
	var shifted_position = position - 16*Vector2.ONE
	position = Vector2( stepify(shifted_position[0],32) + 16 , stepify(shifted_position[1],32) + 16 )



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
	print(normal_pitch_scale)
	print(name," ",normal_pitch_scale + rng.randf_range(-0.2,+0.2))
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
