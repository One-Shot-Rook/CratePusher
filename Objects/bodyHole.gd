extends KinematicBody2D

export var isBottomless:bool = false
var filled = false

func _ready():
	if isBottomless:
		$sprite.texture = load("res://Assets/Sprites/img_hole_endless.png")
	else:
		$sprite.texture = load("res://Assets/Sprites/img_hole_fill.png")

func fillWith(resource_path):
	if isBottomless:
		return
	$sprSunk.texture = load(resource_path)
	$shape.disabled = true

func actionPhase():
	Globals.updateObjectPhaseID(self,"auto") # ACTION (DONE)

func movePhase():
	Globals.updateObjectPhaseID(self,"auto") # MOVE (DONE)

func effectPhase():
	Globals.updateObjectPhaseID(self,"auto") # EFFECT (DONE)

func reactPhase():
	Globals.updateObjectPhaseID(self,"done") # REACT (DONE)
