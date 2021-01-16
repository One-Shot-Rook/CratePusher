tool
extends Node

var button_signals = {}			# button_signals[signal_id:int][buttonNode:Area2D] = bool
var button_goals = {}			# button_goals[buttonNode:Area2D] = bool
var button_colors = [Color.red,Color.blue,Color.green,Color.yellow,Color.purple,Color.darkgoldenrod]
var crate_colors = ["ff8080","187bcd"]

var STAGE_WAIT_TIME = 0.07

func update_move_ui() -> void:
	var crate_array = get_tree().get_nodes_in_group("crate")
	for crate in crate_array:
		if crate.is_moving:
			get_tree().call_group("crate","disable_move_ui")
			print(crate," is still moving")
			return
	yield(get_tree().create_timer(STAGE_WAIT_TIME), "timeout")
	react_to_crate_positions()

func react_to_crate_positions():
	get_tree().call_group("button","update_on_or_off")
	yield(get_tree().create_timer(0.015), "timeout")
	get_tree().call_group("door","update_open_or_close")
	yield(get_tree().create_timer(0.015), "timeout")
	get_tree().call_group("crate","enable_move_ui")
	print("\n [NEW]\n")

func update_buttons_off():
	get_tree().call_group("button","update_on_or_off",true)
	get_tree().call_group("door","update_open_or_close")



### SIGNALS ###

# generate button_signals
func initialise_buttons() -> void:
	var buttonArray = get_tree().get_nodes_in_group("button")
	button_signals = {}
	button_goals = {}
	for button in buttonArray:
		if button.is_level_goal:
			button_goals[button] = false
		elif button_signals.has(button.signal_id):
			button_signals[button.signal_id][button] = false
		else:
			button_signals[button.signal_id] = {button:false}
		#print(button_signals)
	print("button_signals = ",button_signals)
	print("button_goals = ",button_goals)


# update signal state given signal_id, button object and the new state
func update_signal_id(signal_id:int, button:ButtonFloor, newState:bool) -> void:
	if button.is_level_goal:
		return
	button_signals[signal_id][button] = newState
	#print("button_signals = ",button_signals)
# e.g. updateSignal(2, [Area2D:1423], true) --> button_signals[2][[Area2D:1423]] = true


func update_goal(button:ButtonFloor):
	button_goals[button] = true
	print("button_goals = ",button_goals)
	try_to_complete_level()


# return Array of button states for a given signal_id
func get_button_states(signal_id:int) -> Array:
	var button_states = []
	for is_button_active in button_signals[signal_id].values():
		button_states.append(is_button_active)
	return button_states
# e.g. getButtonStates(signal_id = 2) = [true,false,true]


func try_to_complete_level():
	for is_goal_complete in button_goals.values():
		if not is_goal_complete:
			return
	get_tree().call_group("level","endLevel")


func get_button_color(signal_id) -> Color:
	return button_colors[signal_id%button_colors.size()]

func get_crate_color(crate_id) -> Color:
	return crate_colors[crate_id]


