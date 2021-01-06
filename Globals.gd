extends Node

var objectPhases = {}			# objectPhases[buttonNode:Area2D] = phaseID:int (Phases.X)
var buttonSignals = {}			# buttonSignals[signalID:int][buttonNode:Area2D] = bool


onready var gamePhase = Phases.ACTION
onready var next_gamePhase = Phases.MOVE

var buttonColors = [Color.red,Color.blue,Color.green,Color.yellow,Color.purple,Color.darkgoldenrod]

### PHASES ###

# generate objectPhases
func initialiseObjectPhases():
	var objectArray = get_tree().get_nodes_in_group("object")
	objectPhases = {}
	for object in objectArray:
		objectPhases[object] = gamePhase
	#print("objectPhases = ",objectPhases)
	

# update phaseID for a given object
func updateObjectPhaseID(object,_debugString="") -> void:
	#print(object.name," -> ",next_gamePhase," ",debugString)
	objectPhases[object] = next_gamePhase
	if areStatesAligned():
		progressGamePhase()

# return whether all states are at the next gamePhase (i.e. done with the previous gamePhase)
func areStatesAligned() -> bool:
	for object in objectPhases:
		if objectPhases[object] != next_gamePhase:
			return false
	return true

func checkForMovement() -> void:
	var crateArray = get_tree().get_nodes_in_group("crate")
	for crate in crateArray:
		if crate.moving:
			#print(crate.name," is still moving!")
			return
	#print("No crates moving!")
	progressGamePhase()

# begin the next phase
func progressGamePhase() -> void:
	# Updating game phase
	gamePhase = next_gamePhase
	#print("\nGAMEPHASE: ",gamePhase)
	next_gamePhase = (gamePhase+1)%4
	# Force all objects to current game phase
	for object in objectPhases:
		objectPhases[object] = gamePhase
	# START OF PHASE
	processPhase()

# call all objects to perform the corresponding built-in phase-function
func processPhase() -> void:
	if gamePhase == Phases.ACTION:
		LevelData.tryCompleteLevel()
		get_tree().call_group("object","actionPhase")
	elif gamePhase == Phases.MOVE:
		get_tree().call_group("object","movePhase")
	elif gamePhase == Phases.EFFECT:
		get_tree().call_group("object","effectPhase")
	elif gamePhase == Phases.REACT:
		get_tree().call_group("object","reactPhase")



### SIGNALS ###


# generate buttonSignals
func initialiseButtonSignals() -> void:
	var buttonArray = get_tree().get_nodes_in_group("button")
	buttonSignals = {}
	for button in buttonArray:
		if buttonSignals.has(button.signalID):
			buttonSignals[button.signalID][button] = false
		else:
			buttonSignals[button.signalID] = {button:false}
	#print("buttonSignals = ",buttonSignals)


# update signal state given signalID, button object and the new state
func updateSignal(signalID:int, button:Area2D, newState:bool) -> void:
	buttonSignals[signalID][button] = newState
# e.g. updateSignal(2, [Area2D:1423], true) --> buttonSignals[2][[Area2D:1423]] = true


# return Array of button states for a given signalID
func getButtonStates(signalID:int) -> Array:
	var buttonStates = []
	for isButtonActive in buttonSignals[signalID].values():
		buttonStates.append(isButtonActive)
	return buttonStates
# e.g. getButtonStates(signalID = 2) = [true,false,true]

func getButtonColor(signalID) -> Color:
	return buttonColors[signalID%buttonColors.size()]

