extends KinematicBody2D

var moving = false
var direction:Vector2
var tileSize:float
var moveSpeed:float = 45
var rng = RandomNumberGenerator.new()
var interactable = null

var directions = {
	"U":Vector2( 0,-1),
	"R":Vector2(+1, 0),
	"D":Vector2( 0,+1),
	"L":Vector2(-1, 0)
	}

func _ready():
	tileSize = get_parent().scale[0] * 32
	enableMoveUI()

func move(setDirection:Vector2):
	Globals.progressGamePhase() # ACTION -> MOVE
	direction = setDirection
	moving = true
	rng.randomize()
	$audioMove.pitch_scale = rng.randf_range(0.8,1.2)
	$audioMove.play()

func _physics_process(delta):
	if not moving:
		return
	var collisionInfo = move_and_collide(moveSpeed*direction*delta*60)
	if collisionInfo:
		moving = false
		direction = Vector2.ZERO
		var tempPos = position - 16*Vector2.ONE
		position = Vector2( stepify(tempPos[0],32) + 16 , stepify(tempPos[1],32) + 16 ) # Snap position to grid
		Globals.updatePhase(self,"stopped") # MOVE (DONE)

func enableMoveUI():
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
	if not moving:
		Globals.updatePhase(self,"auto") # MOVE (DONE)
	disableMoveUI()

func effectPhase():
	Globals.updatePhase(self,"auto") # EFFECT (DONE)

func displayPhase():
	Globals.updatePhase(self,"auto") # DISPLAY (DONE)



func _on_areaU_pressed():
	move(Vector2(0,-1))

func _on_areaR_pressed():
	move(Vector2(+1,0))

func _on_areaD_pressed():
	move(Vector2(0,+1))

func _on_areaL_pressed():
	move(Vector2(-1,0))
