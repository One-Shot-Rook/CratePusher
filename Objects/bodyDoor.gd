class_name Door, "res://icons/Door.svg"
tool
extends KinematicBody2D

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

func update_open_or_closed(closed_only=false):
	var button_array = get_tree().get_nodes_in_group("button")
	for button in button_array:
		if button.signal_id != signal_id or button.is_level_goal:
			continue
		if button.is_pressed:
			if not closed_only:
				open_door()
			return
	close_door()

func open_door():
	if is_open:
		return
	is_open = true
	$occluder.visible = false
	$shape.disabled = true
	$sprite.frame = 0
	$sprite.play()
	$audioOpen.play()

func close_door():
	if not is_open or not can_close():
		return
	is_open = false
	$occluder.visible = true
	$shape.disabled = false
	$sprite.frame = 9
	$sprite.play("",true)
	$audioClose.play()

func can_close():
	var crateArray = get_tree().get_nodes_in_group("crate")
	for crate in crateArray:
		if (crate.position-position).length() < 16:
			return false
	return true
