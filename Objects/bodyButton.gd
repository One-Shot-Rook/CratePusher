extends Area2D

export var signalID:int
export var levelGoal:bool
var pressed:bool = false



func updateState():
	#print("update")
	#print(pressed,"->",newState)
	var newState = isButtonPressed()
	if newState == true and not pressed: # If the button was just pressed
		$audioClick.play()
	pressed = newState
	Globals.updateSignal(signalID,self,newState)
	Globals.updateObjectPhaseID(self,"effect") # EFFECT (DONE)

func isButtonPressed():
	var crateArray = get_tree().get_nodes_in_group("crate")
	for crate in crateArray:
		if (crate.position-position).length() < 16:
			if levelGoal:
				LevelData.levelComplete = true
			return true
	return false

func actionPhase():
	pass

func movePhase():
	Globals.updateObjectPhaseID(self,"auto") # MOVE (DONE)

func effectPhase():
	updateState()

func reactPhase():
	Globals.updateObjectPhaseID(self,"auto") # REACT (DONE)

