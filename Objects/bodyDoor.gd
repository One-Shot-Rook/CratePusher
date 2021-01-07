class_name Door
extends KinematicBody2D

export var signalID:int
enum DOORMODE{SINGLE,ALL}
export(DOORMODE) var doorMode
var is_open:bool = false

func get_class() -> String: return "Door"

func _ready():
	$sprColor.self_modulate = Globals.get_button_color(signalID)

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
	$sprite.frame = 7
	$sprite.play("",true)
	$audioClose.play()

func update_open_or_close() -> void:
	var button_states = Globals.get_button_states(signalID)
	match doorMode:
		DOORMODE.SINGLE:
			if (true in button_states):
				open_door()
			else:
				close_door()
		DOORMODE.ALL:
			print(button_states)
			if not(false in button_states):
				open_door()
			else:
				close_door()

func can_close():
	var crateArray = get_tree().get_nodes_in_group("crate")
	for crate in crateArray:
		if (crate.position-position).length() < 16:
			return false
	return true
