class_name ButtonFloor, "res://icons/ButtonFloor.svg"
tool
extends Node2D

export var signal_id:int setget set_signal_id, get_signal_id
export var is_level_goal:bool setget set_is_level_goal, get_is_level_goal
enum GoalType{RED,BLUE}
export(GoalType) var goal_type = GoalType.RED setget set_goal_type, get_goal_type
var GoalText = ["Red","Blue"]

var is_pressed:bool = false

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
		{
			name = "is_level_goal",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "goal_type",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Red,Blue",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func get_class() -> String: return "ButtonFloor"

func set_signal_id(new_signal_id):
	signal_id = new_signal_id
	initialise_button()
func get_signal_id() -> int: return signal_id
func set_is_level_goal(new_is_level_goal):
	is_level_goal = new_is_level_goal
	initialise_button()
func get_is_level_goal() -> bool: return is_level_goal
func set_goal_type(new_goal_type) -> void:
	goal_type = new_goal_type
	initialise_button()
func get_goal_type() -> int: return goal_type

func initialise_button():
	$spriteBase/spriteCenter.modulate = Globals.get_button_color(signal_id)
	$spriteBase/spriteCenter.modulate.a = int(not is_level_goal)
	$partGoal.emitting = is_level_goal
	$partGoal.visible = is_level_goal
	$partGoal.modulate = Globals.get_crate_color(goal_type)
	$spriteBase.visible = not is_level_goal
	if is_level_goal:
		$audioClick.stream = load("res://Assets/Sounds/snd_alert.wav")
		name = "goal" + "("+GoalText[goal_type]+")"
	else:
		$audioClick.stream = load("res://Assets/Sounds/snd_button.wav")
		name = "button" + "("+str(signal_id)+")"
	

func update_on_or_off(off_only=false):
	var crate_array = get_tree().get_nodes_in_group("crate")
	for crate in crate_array:
		if (position - crate.position).length() < 4:
			if not off_only:
				activate_button(crate)
			return
	deactivate_button()

func activate_button(crate):
	if not is_pressed: # If the button was just pressed
		$audioClick.play()
	is_pressed = true
	if is_level_goal and goal_type+1 == crate.crate_type:
		$partGoal.modulate = Color(0.2,0.2,0.2)
		Globals.update_goal(self)
		crate.queue_free()
	else:
		Globals.update_signal_id(signal_id,self,is_pressed)

func deactivate_button():
	is_pressed = false
	Globals.update_signal_id(signal_id,self,is_pressed)

