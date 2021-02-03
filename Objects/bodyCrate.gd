class_name Crate, "res://icons/Crate.svg"
tool
extends GameObject

signal crate_move_inputted	# Signals increment move_count
signal crate_move_started	# Singals disable_move_ui
signal crate_step_finished	# Signals buttons (off-mode)
signal crate_move_stopped 	# Signals buttons
signal crate_move_finished	# Signals enable_move_ui check

enum CrateType{WOODEN,RED,BLUE,PURPLE}
enum SpeedMode{SLOW,FAST}
enum WeightMode{LIGHT,MEDIUM,HEAVY}

export(CrateType) var crate_type = CrateType.WOODEN setget set_crate_type, get_crate_type

var keys_pressed = []
var CRATE_KEYS = [KEY_0,KEY_1,KEY_2,KEY_3]
var allow_input := true 
var moves = []

var weight_id:int = WeightMode.MEDIUM
var speed_mode:int = SpeedMode.SLOW

var is_movable := false # Can the user move the crate
var is_interactable := true setget set_is_interactable # Can we currently give the crate user inputs
var invisible := false setget set_invisible

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
var facing_direction = Vector2.RIGHT setget set_facing_direction

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

func set_is_interactable(new_is_interactable) -> void:
	is_interactable = new_is_interactable
	if is_interactable:
		enable_move_ui()
		check_for_next_move()
	else:
		disable_move_ui()

func set_crate_type(new_crate_type) -> void:
	crate_type = new_crate_type
	initialise_crate()
	update_ui()

func set_facing_direction(direction:Vector2) -> void:
	facing_direction = direction
	$sprites.rotation = -facing_direction.angle_to(Vector2(0,1)) + PI

func set_invisible(new_value):
	invisible = new_value
	$sprite.visible = not invisible
	$sprites.visible = not invisible
	if invisible:
		disable_move_ui()
	else:
		enable_move_ui()

func get_crate_type() -> int: return crate_type

func set_mouse_pressed(new_is_mouse_pressed):
	is_mouse_pressed = new_is_mouse_pressed
	set_highlight(new_is_mouse_pressed)

func get_class() -> String: return "Crate"



func _init():
	save_variables = PoolStringArray(["position","is_detectable","allow_input","invisible","facing_direction"])

func _ready() -> void:
	initialise_crate()
	update_ui()

func initialise_crate() -> void:
	match crate_type:
		CrateType.WOODEN:
			name = "crate(Wooden)"
			weight_id = WeightMode.LIGHT
			speed_mode = SpeedMode.SLOW
			move_distance_standard = MOVE_DISTANCE_MAX
			move_time = 0.12
			is_movable = false
			normal_pitch_scale = 1.0
		CrateType.RED:
			name = "crate(Red)"
			weight_id = WeightMode.MEDIUM
			speed_mode = SpeedMode.SLOW
			move_distance_standard = MOVE_DISTANCE_MAX
			move_time = 0.12
			is_movable = true
			normal_pitch_scale = 2
		CrateType.BLUE:
			name = "crate(Blue)"
			weight_id = WeightMode.LIGHT
			speed_mode = SpeedMode.FAST
			move_distance_standard = MOVE_DISTANCE_MAX
			move_time = 0.08
			is_movable = true
			normal_pitch_scale = 2.5
		CrateType.PURPLE:
			name = "crate(Purple)"
			weight_id = WeightMode.HEAVY
			speed_mode = SpeedMode.SLOW
			move_time = 0.16
			move_distance_standard = 2
			is_movable = true
			normal_pitch_scale = 1.5

func update_ui() -> void:
	$trailParticles.emitting = false
	match crate_type:
		CrateType.WOODEN:
			$sprite.visible = true
			$sprite.texture = load("res://Assets/Sprites/svg_crate_wooden.svg")
			$sprites.visible = false
			$audioMove.stream = load("res://Assets/Sounds/snd_crate.wav")
			$audioMove.volume_db = -5
			$audioMove.pitch_scale = 1
		CrateType.RED:
			$sprite.visible = false
			$sprite.texture = Texture
			$sprites/sprHead.texture = load("res://Assets/Sprites/Player/svg_" + Globals.get_crate_head_shape(crate_type) + "_head.svg") 
			$sprites.visible = true
			$audioMove.stream = load("res://Assets/Sounds/snd_running.wav")
			$audioMove.volume_db = 10
		CrateType.BLUE:
			$sprite.visible = false
			$sprite.texture = Texture
			$sprites/sprHead.texture = load("res://Assets/Sprites/Player/svg_" + Globals.get_crate_head_shape(crate_type) + "_head.svg")
			$sprites.visible = true
			$audioMove.stream = load("res://Assets/Sounds/snd_running.wav")
			$audioMove.volume_db = 10
		CrateType.PURPLE:
			$sprite.visible = false
			$sprite.texture = Texture
			$sprites/sprHead.texture = load("res://Assets/Sprites/Player/svg_" + Globals.get_crate_head_shape(crate_type) + "_head.svg")
			$sprites.visible = true
			$audioMove.stream = load("res://Assets/Sounds/snd_running.wav")
			$audioMove.volume_db = 10
	$sprite.modulate =			Globals.get_crate_color(crate_type)
	$sprites/sprHead.modulate =	Globals.get_crate_color(crate_type)
	$Directions.modulate = 		Globals.get_crate_color(crate_type)
	set_facing_direction(facing_direction)

func set_highlight(should_highlight) -> void:
	$sprite.material.set_shader_param("is_highlighted",should_highlight)
	$sprites.material.set_shader_param("is_highlighted",should_highlight)



func start_moving(new_move_direction:Vector2,new_move_distance=move_distance_standard) -> bool:
	# Can the crate move in that direction at all
	move_direction = new_move_direction
	if not is_direction_clear(move_direction):
		return false
	move_distance = new_move_distance
	is_moving = true
	set_facing_direction(move_direction)
	emit_signal("crate_move_started")
	start_move_sound()
	_move()
	return true

func _move(_object=null, _key=":position") -> void:
	
	$trailParticles.emitting = true
	$trailParticles.direction = -move_direction
	should_stop_moving = false
	
	snap_to_tile()
	
	if move_distance <= 0:
		should_stop_moving = true
	move_distance -= 1
	
	emit_signal("crate_step_finished")
	
	# React to what we're on
	react_to_currently_colliding()
	
	if not should_stop_moving:
		# React to what's ahead
		react_to_move_direction()
		
		if should_stop_moving:
			# React to what we're on
			react_to_currently_colliding()
	
	if should_stop_moving:
		$trailParticles.emitting = false
		stop_moving()
	
	if not is_moving:
		return
	
	# Move to next tile
	move_to_position = position + move_direction * Level.cell_size
	$twnMove.interpolate_property(self, "position",
			null, move_to_position, move_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	$twnMove.start()

func stop_moving(_reason="wall") -> void:
	if not is_moving:
		return
	#print(str(name)+" stopped because "+reason)
	is_moving = false
	move_direction = Vector2.ZERO
	move_distance = 0
	stop_move_sound()
	emit_signal("crate_move_stopped") # Signals buttons
	emit_signal("crate_move_finished") # Signals enable move ui check

func check_for_next_move() -> void:
	if not moves.empty():
		direction_pressed(moves.pop_front())



func react_to_currently_colliding() -> void:
	var object_currently_colliding = get_object_currently_colliding()
	if object_currently_colliding:
		#print("currently on: ",object_currently_colliding.get_class())
		match object_currently_colliding.get_class():
			"Hole":
				var hole = object_currently_colliding
				if hole.is_filled:
					continue
				if speed_mode == SpeedMode.FAST and not should_stop_moving:
					continue
				hole.fill_with($sprite.texture)
				should_stop_moving = true
				disappear()
			"Goal":
				var goal:Goal = object_currently_colliding
				if goal.is_correct_level_goal(self):
					should_stop_moving = true
					disappear()
			"LaunchPad":
				var launch_pad = object_currently_colliding
				move_direction = launch_pad.get_direction_vector()
				move_distance = move_distance_standard - 1
				should_stop_moving = false
				set_facing_direction(move_direction)

func get_object_currently_colliding() -> Node:
	for object in Level.get_object_array():
		if object == self:
			continue
		if object.position == position:
			return object
	return null



func react_to_move_direction() -> void:
	var objects = get_objects_in_direction()
	#print("Objects ahead: ",objects)
	for object in objects:
		match object.get_class():
			"TileMap":
				should_stop_moving = true
			"Door":
				var door = object
				if not door.is_open:
					should_stop_moving = true
			"Crate":
				var crate:Crate = object
				var push_distance = weight_id-crate.weight_id
				#print("PUSH ",name," ["+str(weight_id)+"|"+str(crate.weight_id)+"]",str(crate.name))
				if push_distance > 0:
					var _moved = crate.start_moving(move_direction,push_distance)
				should_stop_moving = true

func get_objects_in_direction(direction:Vector2=move_direction) -> Array:
	var objects = []
	var scan_position = position + direction * Level.cell_size
	for object in Level.get_object_array():
		if object.position == scan_position:
			objects.append(object)
	if scan_position in Level.get_tile_positions(Level.TileID.TILE_WALL):
		objects.append(Level)
	return objects

func is_direction_clear(direction:Vector2=move_direction) -> bool:
	var objects = get_objects_in_direction(direction)
	for object in objects:
		match object.get_class():
			"TileMap":
				return false
			"Door":
				var door = object
				if not door.is_open:
					return false
			"Crate":
				var crate:Crate = object
				if crate.is_detectable:
					return false
	return true



func disappear() -> void:
	allow_input = false
	is_detectable = false
	set_invisible(true)

func reappear() -> void:
	allow_input = true
	is_detectable = true
	set_invisible(false)

func has_move_distance() -> bool:
	return (move_distance > 0)

func enable_move_ui() -> void:
	if not is_movable or Level.is_level_complete or invisible:
		return
	is_interactable = true
	for dir_char in directions:
		var direction = directions[dir_char]
		get_node("Directions/spr"+dir_char).visible = is_direction_clear(direction)
	$Directions.visible = true

func disable_move_ui() -> void:
	$Directions.visible = false
	is_interactable = false



func start_move_sound() -> void:
	rng.randomize()
	$audioMove.pitch_scale = normal_pitch_scale + rng.randf_range(-0.2,0.2)
	$audioMove.play()
	$sprites/aniPlayer.play("Running")

func stop_move_sound() -> void:
	if crate_type == CrateType.WOODEN:
		return
	$audioMove.stop()
	$sprites/aniPlayer.stop()
	$sprites/aniPlayer.seek(0.0,true)



func direction_pressed(new_move_direction:Vector2) -> void:
	if not is_interactable:
		if is_movable:
			moves.append(new_move_direction)
		return
	if start_moving(new_move_direction):
		emit_signal("crate_move_inputted")

func get_nearest_direction(vector:Vector2) -> Vector2:
	var nearest_direction = directions["U"]
	for vector_direction in directions.values():
		var direction_distance = (vector_direction-vector).length()
		var nearest_distance = (nearest_direction-vector).length()
		if direction_distance < nearest_distance:
			nearest_direction = vector_direction
	return nearest_direction



func _on_mouse_input_event(_viewport, event, _shape_idx) -> void:
	
	if not is_interactable or not allow_input:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if get_local_mouse_position().length() <= 48:
					set_mouse_pressed(true)
			else:
				set_mouse_pressed(false)

func _on_mouse_exited() -> void:
	
	if not is_interactable or not allow_input:
		return
	
	if is_mouse_pressed and is_movable:
		
		var local_mouse_position = get_local_mouse_position()
		var nearest_direction = get_nearest_direction(local_mouse_position)
		direction_pressed(nearest_direction)
	
	set_mouse_pressed(false)

func _unhandled_key_input(event) -> void:
	
	if not allow_input:
		return
	
	# Erase released key
	if not event.pressed and event.scancode in keys_pressed:
		keys_pressed.erase(event.scancode)
	
	# Highlight if crate key is pressed
	if event.scancode == CRATE_KEYS[crate_type]:
		set_highlight(event.pressed)
	
	# If key is already pressed
	if event.scancode in keys_pressed:
		return
	
	# Append new pressed key
	if event.pressed:
		keys_pressed.append(event.scancode)
	
	# Interpret direction input
	if CRATE_KEYS[crate_type] in keys_pressed:
		if KEY_UP in keys_pressed:
			direction_pressed(Vector2.UP)
		elif KEY_RIGHT in keys_pressed:
			direction_pressed(Vector2.RIGHT)
		elif KEY_DOWN in keys_pressed:
			direction_pressed(Vector2.DOWN)
		elif KEY_LEFT in keys_pressed:
			direction_pressed(Vector2.LEFT)

