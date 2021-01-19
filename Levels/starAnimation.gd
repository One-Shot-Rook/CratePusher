extends Node2D

onready var sprStarNodes = [$sprStar0,$sprStar1,$sprStar2]

# Stars
export var stars_max:int = 4
export var stars_achieved:int = 2

# Rotation of individual stars
export var rotation_time:float = 5

# Rotation of all stars around center
export var cycle_time:float = 3
export var cycle_rotations:float = 1

# Fade-in of stars
export var fade_time:float = 2

# Radius of stars from center
export var radius_time:float = 3
export var radius_initial:float = 225
export var radius_final:float = 85

# Colors for star types
export var color_achieved:Color
export var color_unachieved:Color
export var color_perfected:Color

func _ready():
	start()

func start(given_stars_achieved = stars_achieved):
	visible = false
	stars_achieved = given_stars_achieved
	for ID in sprStarNodes.size():
		
		var sprStar = sprStarNodes[ID]
		var color_star = Color.white
		if stars_achieved < stars_max:
			if ID >= stars_achieved:
				color_star = color_unachieved - Color(0,0,0,0.85)
			else:
				color_star = color_achieved
		else:
			color_star = color_perfected
		
		var position_start = Vector2.ONE.rotated(ID*PI*2/3) * radius_initial
		var position_final = Vector2.ONE.rotated(ID*PI*2/3) * radius_final
		$twnRotation.interpolate_property(sprStar,"rotation",
				0,2*PI,rotation_time,
				Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
		$twnRadius.interpolate_property(sprStar,"position",
				position_start,position_final,radius_time,
				Tween.TRANS_LINEAR,Tween.EASE_IN)
		$twnFade.interpolate_property(sprStar,"modulate",
				Color(0,0,0,0),color_star,fade_time,
				Tween.TRANS_LINEAR,Tween.EASE_IN)
	$twnCycle.interpolate_property(self,"rotation",
			cycle_rotations*2*PI,0,cycle_time,
			Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$twnRadius.start()
	$twnRotation.start()
	$twnFade.start()
	$twnCycle.start()

func _on_twnFade_tween_started(_object, _key):
	visible = true
