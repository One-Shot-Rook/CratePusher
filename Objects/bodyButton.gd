class_name ButtonFloor
extends Area2D

export var signal_id:int
export var is_level_goal:bool
var is_pressed:bool = false

func get_class() -> String: return "ButtonFloor"

func _ready():
	$spriteBase/spriteCenter.modulate = Globals.get_button_color(signal_id)
	$spriteBase/spriteCenter.modulate.a = int(not is_level_goal)
	$partGoal.emitting = is_level_goal
	$partGoal.visible = is_level_goal
	$spriteBase.visible = not is_level_goal
	if is_level_goal:
		$audioClick.stream = load("res://Assets/Sounds/snd_alert.wav")
	else:
		$audioClick.stream = load("res://Assets/Sounds/snd_button.wav")

func update_on_or_off():
	var crate_array = get_tree().get_nodes_in_group("crate")
	for crate in crate_array:
		if (position - crate.position).length() < 4:
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

