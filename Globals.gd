extends Node

var objects = {}
onready var gamePhase = Phases.ACTION
onready var next_gamePhase = Phases.MOVE

func initialseObjectStates(objectArray):
	for object in objectArray:
		objects[object] = Phases.ACTION

func updatePhase(object,debugString=""):
	print(object.name," -> ",next_gamePhase," ",debugString)
	objects[object] = next_gamePhase
	if areStatesAligned():
		progressGamePhase()

func areStatesAligned():
	for object in objects:
		if objects[object] != next_gamePhase:
			return false
	return true

func progressGamePhase():
	# Updating game phase
	gamePhase = next_gamePhase
	print("\nGAMEPHASE: ",gamePhase)
	next_gamePhase = (gamePhase+1)%4
	# Force all objects to current game phase
	for object in objects:
		objects[object] = gamePhase
	# START OF PHASE
	processPhase()

func resetObjectStates():
	for object in objects:
		objects[object] = Phases.ACTION

func processPhase():
	if gamePhase == Phases.ACTION:
		get_tree().call_group("object","actionPhase")
	elif gamePhase == Phases.MOVE:
		get_tree().call_group("object","movePhase")
	elif gamePhase == Phases.EFFECT:
		get_tree().call_group("object","effectPhase")
	elif gamePhase == Phases.DISPLAY:
		get_tree().call_group("object","displayPhase")
