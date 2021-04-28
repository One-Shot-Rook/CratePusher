class_name ButtonFloor, "res://icons/ButtonFloor.svg"
tool
extends GameObject

signal button_pressed(animate)	# Signals doors
signal button_released(animate)	# Signals doors
signal button_changed(animate)

export var signal_id:int setget set_signal_id, get_signal_id

var is_pressed:bool = false setget set_is_pressed

func _get_property_list() -> Array:
	return [
		{
			name = "ButtonFloor",
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
	]

func get_class() -> String: return "ButtonFloor"

func set_signal_id(new_signal_id):
	signal_id = new_signal_id
	initialise_button()

func set_is_pressed(new_value):
	if new_value:
		activate_button()
	else:
		deactivate_button()

func get_signal_id() -> int: return signal_id



func initialise_button():
	$spriteBase/spriteCenter.modulate = Globals.get_button_color(signal_id)
	$audioClick.stream = load("res://Assets/Sounds/snd_button.wav")
	name = "button" + "("+str(signal_id)+")"

func update_on_or_off():
	for crate in Level.get_objects_by_class("Crate"):
		if position == crate.position:
			activate_button()
			return
	deactivate_button()

func update_off():
	for crate in Level.get_objects_by_class("Crate"):
		if position == crate.position:
			return
	deactivate_button()

func activate_button():
	if not is_pressed: # If the button wasn't pressed
		if Level.animate:
			$audioClick.play()
		emit_signal("button_pressed")
	is_pressed = true
	emit_signal("button_changed")

func deactivate_button():
	if is_pressed:
		emit_signal("button_released")
	is_pressed = false
	emit_signal("button_changed")



