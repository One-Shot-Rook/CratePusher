class_name Door, "res://icons/Door.svg"
tool
extends GameObject

export var signal_id:int setget set_signal_id, get_signal_id

var is_open:bool = false

func _get_property_list() -> Array:
	return [
		{
			name = "Door",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "signal_id",
			type = TYPE_INT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,6",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "door_mode",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Single,All",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func set_signal_id(new_signal_id):
	signal_id = new_signal_id
	initialise_door()

func get_signal_id() -> int: return signal_id

func get_class() -> String: return "Door"



func _ready():
	initialise_door()

func initialise_door():
	name = "door" + "("+str(signal_id)+")"
	$sprColor.self_modulate = Globals.get_button_color(signal_id)



func open_door(animate:bool):
	if is_open:
		return
	is_open = true
	$occluder.visible = false
	if animate:
		animate_open()
	else:
		$sprite.frame = $sprite.frames.get_frame_count("default") - 1

func close_door(animate:bool):
	if not is_open or not can_close():
		return
	is_open = false
	$occluder.visible = true
	if animate:
		animate_close()
	else:
		$sprite.frame = 0

func can_close():
	var crateArray = get_tree().get_nodes_in_group("crate")
	for crate in crateArray:
		if (crate.position-position).length() < tile_size/2:
			return false
	return true

func animate_close():
	$sprite.play("",true) # reverse the animation
	$audioOpen.stop()
	$audioClose.play()

func animate_open():
	$sprite.play() # play the animation
	$audioClose.stop()
	$audioOpen.play()



