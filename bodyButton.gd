extends Area2D

export var signalID:int
var pressed:bool = false
var newState:bool = false

func _ready():
	pass # Replace with function body.

func updateState():
	#print("update")
	#print(pressed,"->",newState)
	# If we have changed state
	var newState = isButtonPressed()
	if newState == true:
		if pressed == false:
			$audioClick.play()
		get_tree().call_group("door","openDoor",signalID)
	else:
		get_tree().call_group("door","closeDoor",signalID)
	pressed = newState
	Globals.updatePhase(self,"effect") # EFFECT (DONE)

func isButtonPressed():
	var crateArray = get_tree().get_nodes_in_group("crate")
	for crate in crateArray:
		if (crate.position-position).length() < 16:
			return true
	return false

func actionPhase():
	pass

func movePhase():
	Globals.updatePhase(self,"auto") # MOVE (DONE)

func effectPhase():
	updateState()

func displayPhase():
	Globals.updatePhase(self,"auto") # DISPLAY (DONE)

