extends KinematicBody2D

var tileSize:float
var rng = RandomNumberGenerator.new()

export var movable:bool = true
var moving = false
var direction:Vector2
var moveSpeed:float = 45
var distanceToMove:float = 0.0

var interactable = null

var MOVE_MAX = 9999
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
	if movable:
		enableMoveUI()
	else:
		disableMoveUI()
	

func move(setDirection:Vector2,distance=MOVE_MAX):
	# Can the crate move in that direction at all
	var collisionInfo = move_and_collide(setDirection*tileSize,true,true,true)
	if collisionInfo:
		if not collisionInfo.collider.is_in_group("hole"):
			return
	distanceToMove = distance
	direction = setDirection
	moving = true
	rng.randomize()
	$audioMove.pitch_scale = rng.randf_range(0.8,1.2)
	$audioMove.play()

func stop(reason="wall"):
	if not moving:
		return
	print(str(name)+": "+reason)
	moving = false
	direction = Vector2.ZERO
	distanceToMove = 0.0
	snapPositionToGrid()
	Globals.checkForMovement() # potentially MOVE (DONE)

func _physics_process(delta):
	if not moving:
		return
	var moveVector = moveSpeed*direction*delta*60
	var collisionInfo = move_and_collide(moveVector)
	distanceToMove -= moveVector.length()
	if outOfMovement():
		stop("friction")
	elif collisionInfo: # We've collided with something
		if collisionInfo.collider.is_in_group("crate"): # If we've hit another crate
			var crate = collisionInfo.collider
			var pushDistance = max(0,weightID-crate.weightID)*tileSize
			#print(" !!! PUSH = ",pushDistance," !!!")
			crate.move(direction,pushDistance)
			stop("crate -> "+str(pushDistance/48))
		if collisionInfo.collider.is_in_group("hole"): # If we've hit a hole
			print("hole")
			var hole = collisionInfo.collider
			hole.fillWith($sprite.texture.resource_path)
			visible = false
			$shape.disabled = true
			position = hole.position
			stop("hole")
		else:
			stop()

func outOfMovement():
	if distanceToMove <= 0:
		return true
	return false

func snapPositionToGrid():
	var tempPos = position - 16*Vector2.ONE
	position = Vector2( stepify(tempPos[0],32) + 16 , stepify(tempPos[1],32) + 16 )

func enableMoveUI():
	if not movable or LevelData.levelComplete:
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
		if directionNode:
			if directionNode.collider.is_in_group("hole"):
				directionNode = null
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


func _on_direction_pressed(extra_arg_0):
	Globals.progressGamePhase() # ACTION -> MOVE
	move(extra_arg_0)
	LevelData.incrementMoveCount()


func _on_Area2D_mouse_exited():
	print("leave")
