class_name Goal, "res://icons/Goal.svg"
tool
extends GameObject

signal level_goal_completed	# Signals is_level_complete check

enum GoalType{WOODEN,RED,BLUE,PURPLE}

export(GoalType) var goal_type = GoalType.RED setget set_goal_type, get_goal_type

var is_complete = false
var GoalText = ["Wooden","Red","Blue","Purple"]

func _get_property_list() -> Array:
	return [
		{
			name = "Goal",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "goal_type",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Wooden,Red,Blue,Purple",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func get_class() -> String: return "Goal"

func set_goal_type(new_goal_type) -> void:
	goal_type = new_goal_type
	initialise_goal()

func get_goal_type() -> int: return goal_type



func initialise_goal():
	$partGoal.modulate = Globals.get_crate_color(goal_type)
	name = "goal" + "("+GoalText[goal_type]+")"

func try_to_complete():
	if is_complete:
		return
	for crate in Level.objects.Crate:
		if crate.position == position:
			if is_correct_level_goal(crate):
				is_complete = true
				$partGoal.modulate = Color(0.2,0.2,0.2)
				$audioClick.play()
				emit_signal("level_goal_completed")

func is_correct_level_goal(crate):
	return (crate.crate_type == goal_type)

