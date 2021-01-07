extends Node

var button_signals = {}			# buttonSignals[signal_id:int][buttonNode:Area2D] = bool
var buttonColors = [Color.red,Color.blue,Color.green,Color.yellow,Color.purple,Color.darkgoldenrod]

var STAGE_WAIT_TIME = 0.07

func update_move_ui() -> void:
	var crate_array = get_tree().get_nodes_in_group("crate")
	for crate in crate_array:
		if crate.is_moving:
			get_tree().call_group("crate","disable_move_ui")
			return
	yield(get_tree().create_timer(STAGE_WAIT_TIME), "timeout")
	get_tree().call_group("button","update_on_or_off")
	yield(get_tree().create_timer(STAGE_WAIT_TIME), "timeout")
	get_tree().call_group("door","update_open_or_close")
	yield(get_tree().create_timer(STAGE_WAIT_TIME), "timeout")
	get_tree().call_group("crate","enable_move_ui")
	print("\n [NEW]\n")



### SIGNALS ###

# generate button_signals
func initialiseButtonSignals() -> void:
	var buttonArray = get_tree().get_nodes_in_group("button")
	button_signals = {}
	for button in buttonArray:
		if button.is_level_goal:
			print("miss")
			pass
		elif button_signals.has(button.signal_id):
			print("add")
			button_signals[button.signal_id][button] = false
		else:
			print("create")
			button_signals[button.signal_id] = {button:false}
		print(button_signals)
	#print("button_signals = ",button_signals)


# update signal state given signal_id, button object and the new state
func update_signal_id(signal_id:int, button:ButtonFloor, newState:bool) -> void:
	if button.is_level_goal:
		return
	button_signals[signal_id][button] = newState
# e.g. updateSignal(2, [Area2D:1423], true) --> button_signals[2][[Area2D:1423]] = true


# return Array of button states for a given signal_id
func get_button_states(signal_id:int) -> Array:
	var button_states = []
	for is_button_active in button_signals[signal_id].values():
		button_states.append(is_button_active)
	return button_states
# e.g. getButtonStates(signal_id = 2) = [true,false,true]


func get_button_color(signal_id) -> Color:
	return buttonColors[signal_id%buttonColors.size()]

