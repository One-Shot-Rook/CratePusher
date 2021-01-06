class_name Crate
extends KinematicBody2D

enum WeightMode{LIGHT,MEDIUM,HEAVY}
export(WeightMode) var weight_id = WeightMode.MEDIUM
export var movable:bool = true

var tile_size:float
var rng := RandomNumberGenerator.new()

var is_moving := false
var move_direction:Vector2
var move_to_position:Vector2
var move_time := 0.05			# In seconds
var move_distance := 0			# In tiles
var MOVE_DISTANCE_MAX := 9999	# In tiles

var interactable:Node = null

var COLLISION_RADIUS := 4

var directions = {"U":Vector2( 0,-1),"R":Vector2(+1, 0),"D":Vector2( 0,+1),"L":Vector2(-1, 0)}

func get_class() -> String: return "Crate"

func _ready():
	tile_size = 32
	snap_to_tile()
	if movable:
		enable_move_ui()
	else:
		disable_move_ui()


func start_moving(new_move_direction:Vector2,new_move_distance=MOVE_DISTANCE_MAX) -> void:
	move_distance = new_move_distance
	move_direction = new_move_direction
	is_moving = true
	Globals.update_move_ui()
	# Can the crate move in that direction at all
	if _move():
		play_move_sound()

func _move(_object=null, _key=":position") -> bool:
	
	snap_to_tile()
	
	if move_distance <= 0:
		stop_moving("friction")
	move_distance -= 1
	
	# React to what we're on
	var object_currently_colliding = get_object_currently_colliding()
	if object_currently_colliding:
		print("currently on: ",object_currently_colliding.get_class())
		match object_currently_colliding.get_class():
			"Hole":
				var hole:Hole = object_currently_colliding
				if hole.is_filled:
					continue
				hole.fill_with($sprite.texture.resource_path)
				stop_moving("fell into hole")
				queue_free()
	
	if not is_moving:
		return false
	
	# React to what's ahead
	var objects_in_move_direction = get_objects_in_move_direction()
	for object in objects_in_move_direction:
		match object.get_class():
			"TileMap":
				stop_moving("Wall")
			"Door":
				var door:Door = object
				if not door.is_open:
					stop_moving("Door")
			"Crate":
				var crate:Crate = object
				var push_distance = max(0,weight_id-crate.weight_id)
				crate.start_moving(move_direction,push_distance)
				stop_moving("crate -> "+str(push_distance/48))
	
	if not is_moving:
		return false
	
	# Move to next tile
	move_to_position = position + move_direction * tile_size
	$twnMove.interpolate_property(self, "position",
			null, move_to_position, move_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	$twnMove.start()
	
	return true
	

func stop_moving(reason="wall"):
	if not is_moving:
		return
	print(str(name)+" stopped because "+reason)
	is_moving = false
	move_direction = Vector2.ZERO
	move_distance = 0
	Globals.update_move_ui()


func get_objects_in_move_direction() -> Array:
	var objects = []
	var object_array = get_tree().get_nodes_in_group("object")
	for object in object_array:
		if (object.position - (position+move_direction*tile_size)).length() <= COLLISION_RADIUS:
			objects.append(object)
	var collision_data = move_and_collide(move_direction*tile_size/3,true,true,true)
	if collision_data:
		objects.append(collision_data.collider)
	return objects


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
	if not movable or LevelData.levelComplete:
		return
	var adjacent_objects = get_objects_adjacent()
	for dirChar in adjacent_objects:
		var adjacentNode = adjacent_objects[dirChar]
		get_node("Directions/area"+dirChar).visible = (adjacentNode == null)
	$Directions.visible = true


func disable_move_ui() -> void:
	$Directions.visible = false


func play_move_sound():
	rng.randomize()
	$audioMove.pitch_scale = rng.randf_range(0.8,1.2)
	$audioMove.play()


func _on_direction_pressed(new_move_direction:Vector2):
	start_moving(new_move_direction)
	LevelData.incrementMoveCount()


func _on_Area2D_mouse_exited():
	print("leave")
