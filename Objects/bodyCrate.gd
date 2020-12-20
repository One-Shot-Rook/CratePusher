extends KinematicBody2D

var tileSize:float
var rng = RandomNumberGenerator.new()

export var movable:bool = true
var moving = false
var direction:Vector2
var moveSpeed:float = 45
var moveAmount:int = 99
var fromPosition:Vector2

var interactable = null

var MOVE_MAX = 99
enum WEIGHTMODE{LIGHT,MEDIUM,HEAVY}
export(WEIGHTMODE) var weightID = WEIGHTMODE.MEDIUM

var directions = {
	"U":Vector2( 0,-1),
	"R":Vector2(+1, 0),
	"D":Vector2( 0,+1),
	"L":Vector2(-1, 0)
	}



func _ready():
	tileSize = get_parent().scale[0] * 32
	snapPositionToGrid()
	recordCurrentPosition()
	enableMoveUI()

func recordCurrentPosition():
	fromPosition = position

func move(setDirection:Vector2,distance=MOVE_MAX):
	moveAmount = distance
	direction = setDirection
	moving = true
	if Globals.gamePhase == Phases.ACTION:
		Globals.progressGamePhase() # ACTION -> MOVE
	rng.randomize()
	$audioMove.pitch_scale = rng.randf_range(0.8,1.2)
	$audioMove.play()

func stop(reason="wall"):
	moving = false
	direction = Vector2.ZERO
	snapPositionToGrid()
	recordCurrentPosition()
	if reason != "crate":
		Globals.checkForMovement() # potentially MOVE (DONE)

func _physics_process(delta):
	if not moving:
		return
	var collisionInfo = move_and_collide(moveSpeed*direction*delta*60)
	if outOfMovement():
		stop("friction")
	elif collisionInfo: # We've collided with something
		if collisionInfo.collider.is_in_group("crate"): # If we've hit another crate
			var crate = collisionInfo.collider
			var pushDistance = max(0,weightID-crate.weightID)
			print(" !!! PUSH = ",pushDistance," !!!")
			crate.move(direction,pushDistance)
			stop("crate")
		else:
			stop()

func outOfMovement():
	if moveAmount == MOVE_MAX:
		return false
	print(moveAmount)
	if (fromPosition-position).length() >= tileSize*moveAmount/3:
		return true
	return false

func snapPositionToGrid():
	var tempPos = position - 16*Vector2.ONE
	position = Vector2( stepify(tempPos[0],32) + 16 , stepify(tempPos[1],32) + 16 )

func enableMoveUI():
	if not movable:
		return
	var adjacentNodes = getAdjacentNodes()
	for dirChar in adjacentNodes:
		var adjacentNode = adjacentNodes[dirChar]
		get_node("Directions/area"+dirChar).visible = (adjacentNode == null)
	$Directions.visible = true

func disableMoveUI():
	$Directions.visible = false

func getAdjacentNodes():
	#print()
	#print(name)
	var adjacentNodes = {}
	for dirChar in directions:
		var vector = directions[dirChar]
		var directionNode = move_and_collide(vector*tileSize/2,true,true,true)
		adjacentNodes[dirChar] = directionNode
		#print(dirChar," is ",directionNode)
	return adjacentNodes


func actionPhase():
	enableMoveUI()

func movePhase():
	disableMoveUI()

func effectPhase():
	Globals.updateObjectPhaseID(self,"auto") # EFFECT (DONE)

func reactPhase():
	Globals.updateObjectPhaseID(self,"auto") # REACT (DONE)



func _on_areaU_pressed():
	move(Vector2(0,-1))

func _on_areaR_pressed():
	move(Vector2(+1,0))

func _on_areaD_pressed():
	move(Vector2(0,+1))

func _on_areaL_pressed():
	move(Vector2(-1,0))
