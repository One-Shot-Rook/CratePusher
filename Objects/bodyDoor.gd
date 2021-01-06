extends KinematicBody2D

export var signalID:int
enum DOORMODE{SINGLE,ALL}
export(DOORMODE) var doorMode
var open:bool = false

func _ready():
	$sprColor.self_modulate = Globals.getButtonColor(signalID)

func openDoor():
	open = true
	$occluder.visible = false
	$shape.disabled = true
	$sprite.frame = 0
	$sprite.play()
	$audioOpen.play()

func closeDoor():
	open = false
	$occluder.visible = true
	$shape.disabled = false
	$sprite.frame = 7
	$sprite.play("",true)
	$audioClose.play()

func shouldDoorBEOpen():
	var buttonStates = Globals.getButtonStates(signalID)
	match doorMode:
		DOORMODE.SINGLE:
			return (true in buttonStates)
		DOORMODE.ALL:
			return not(false in buttonStates)

func canClose():
	var crateArray = get_tree().get_nodes_in_group("crate")
	for crate in crateArray:
		if (crate.position-position).length() < 16:
			return false
	return true

func actionPhase():
	pass

func movePhase():
	Globals.updateObjectPhaseID(self,"auto") # MOVE (DONE)

func effectPhase():
	Globals.updateObjectPhaseID(self,"auto") # EFFECT (DONE)

func reactPhase():
	if shouldDoorBEOpen():
		if not open:
			openDoor()
	else:
		if open and canClose():
			closeDoor()
	Globals.updateObjectPhaseID(self,"done") # REACT (DONE)
