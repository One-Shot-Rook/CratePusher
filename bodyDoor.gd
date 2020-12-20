extends KinematicBody2D

export var signalID:int
enum DOORMODE{SINGLE,ALL}
export(DOORMODE) var doorMode
var open:bool = false



func openDoor():
	open = true
	$shape.disabled = true
	$sprite.frame = 0
	$sprite.play()
	$audioOpen.play()

func closeDoor():
	open = false
	$shape.disabled = false
	$sprite.frame = 7
	$sprite.play("",true)
	$audioClose.play()

func doesDoorOpen():
	var buttonStates = Globals.getButtonStates(signalID)
	match doorMode:
		DOORMODE.SINGLE:
			return (true in buttonStates)
		DOORMODE.ALL:
			return not(false in buttonStates)

func actionPhase():
	pass

func movePhase():
	Globals.updateObjectPhaseID(self,"auto") # MOVE (DONE)

func effectPhase():
	Globals.updateObjectPhaseID(self,"auto") # EFFECT (DONE)

func reactPhase():
	if doesDoorOpen():
		if not open:
			openDoor()
	else:
		if open:
			closeDoor()
	Globals.updateObjectPhaseID(self,"done") # REACT (DONE)
