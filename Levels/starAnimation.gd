extends Node2D

var origin = Vector2(0,0)
var total_stars = 0 # number of stars achieved in level
onready var sprStarNodes = [$sprStar0,$sprStar1,$sprStar2,$sprStar3]

export var stars_max:int = 4
export var stars_achieved:int = 2

export var rotation_time:float = 5

export var cycle_time:float = 3
export var cycle_rotations:float = 1

export var radius_time:float = 3
export var radius_initial:float = 550
export var radius_final:float = 85

func _ready():
	start()

func start(given_stars_achieved = stars_achieved):
	stars_achieved = given_stars_achieved
	for ID in sprStarNodes.size():
		var sprStar = sprStarNodes[ID]
		if ID >= stars_achieved:
			sprStar.visible = false
			continue
		sprStar.visible = true
		var position_start = Vector2.ONE.rotated(ID*PI/2) * radius_initial
		var position_final = Vector2.ONE.rotated(ID*PI/2) * radius_final
		$twnRotation.interpolate_property(sprStar,"rotation",
				0,2*PI,rotation_time,
				Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
		$twnRadius.interpolate_property(sprStar,"position",
				position_start,position_final,radius_time,
				Tween.TRANS_LINEAR,Tween.EASE_IN)
	$twnCycle.interpolate_property(self,"rotation",
			cycle_rotations*2*PI,0,cycle_time,
			Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$twnRadius.start()
	$twnRotation.start()
	$twnCycle.start()

