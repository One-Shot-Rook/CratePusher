extends KinematicBody2D

export var signalID:int
var open:bool = false

func _ready():
	pass # Replace with function body.

func openDoor(active_signalID):
	if active_signalID != signalID or open:
		Globals.updatePhase(self,"open (no change)") # EFFECT (DONE)
		return
	open = true
	$shape.disabled = true
	$sprite.frame = 0
	$sprite.play()
	$audioOpen.play()
	Globals.updatePhase(self,"open") # EFFECT (DONE)

func closeDoor(active_signalID):
	if active_signalID != signalID or not open:
		Globals.updatePhase(self,"close (no change)") # EFFECT (DONE)
		return
	open = false
	$shape.disabled = false
	$sprite.frame = 7
	$sprite.play("",true)
	$audioClose.play()
	Globals.updatePhase(self,"close") # EFFECT (DONE)

func actionPhase():
	pass

func movePhase():
	Globals.updatePhase(self,"auto") # MOVE (DONE)

func effectPhase():
	pass # Intentional

func displayPhase():
	Globals.updatePhase(self,"auto") # DISPLAY (DONE)
