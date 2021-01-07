class_name ButtonFloor
tool
extends Area2D

export var signal_id:int setget set_signal_id, get_signal_id
export var is_level_goal:bool setget set_is_level_goal, get_is_level_goal
var is_pressed:bool = false

func get_class() -> String: return "ButtonFloor"

func set_signal_id(new_signal_id):
	signal_id = new_signal_id
	update_ui()
func get_signal_id() -> int: return signal_id
func set_is_level_goal(new_is_level_goal):
	is_level_goal = new_is_level_goal
	update_ui()
func get_is_level_goal() -> bool: return is_level_goal

func update_ui():
	$spriteBase/spriteCenter.modulate = Globals.get_button_color(signal_id)
	$spriteBase/spriteCenter.modulate.a = int(not is_level_goal)
	$partGoal.emitting = is_level_goal
	$partGoal.visible = is_level_goal
	$spriteBase.visible = not is_level_goal
	if is_level_goal:
		$audioClick.stream = load("res://Assets/Sounds/snd_alert.wav")
	else:
		$audioClick.stream = load("res://Assets/Sounds/snd_button.wav")

func update_on_or_off(off_only=false):
	var crate_array = get_tree().get_nodes_in_group("crate")
	for crate in crate_array:
		if (position - crate.position).length() < 4:
			if not off_only:
				activateButton()
			return
	deactivateButton()

func activateButton():
	if not is_pressed: # If the button was just pressed
		$audioClick.play()
	is_pressed = true
	if is_level_goal:
		LevelData.levelComplete = true
		LevelData.tryCompleteLevel()
	else:
		Globals.update_signal_id(signal_id,self,is_pressed)

func deactivateButton():
	is_pressed = false
	Globals.update_signal_id(signal_id,self,is_pressed)

