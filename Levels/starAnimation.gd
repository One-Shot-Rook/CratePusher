class_name MerryGo
extends Node2D

onready var sprite_array = [$sprStar0,$sprStar1,$sprStar2]

onready var twnRotation:Tween = $twnRotation
onready var twnFade:Tween = $twnFade
onready var twnCycle:Tween = $twnCycle
onready var twnRadius:Tween = $twnRadius

# Stars
export var stars_max:int = 4
export var stars_achieved:int = 2
export var stars_texture:Texture

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

func get_class() -> String: return "MerryGo"

func _ready():
	start()

func _draw():
	
	return
	
	var initial_points_array = []
	for spriteID in range(sprite_array.size()):
		initial_points_array.append(radius_initial * Vector2.ONE.rotated(spriteID*2*PI/sprite_array.size()))
	draw_multiline(initial_points_array,Color.red,3)
	
	var final_points_array = []
	for spriteID in range(sprite_array.size()):
		final_points_array.append(radius_final * Vector2.ONE.rotated(spriteID*2*PI/sprite_array.size()))
	draw_multiline(final_points_array,Color.red,3)

func start(given_stars_achieved = stars_achieved):
	visible = false
	stars_achieved = given_stars_achieved
	for ID in sprite_array.size():
		
		var sprStar = sprite_array[ID]
		var color_star = get_star_color(ID)
		
		var position_start = Vector2.ONE.rotated(ID*PI*2/3) * radius_initial
		var position_final = Vector2.ONE.rotated(ID*PI*2/3) * radius_final
		twnRotation.interpolate_property(sprStar,"rotation",
				0,2*PI,rotation_time,
				Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
		twnRadius.interpolate_property(sprStar,"position",
				position_start,position_final,radius_time,
				Tween.TRANS_LINEAR,Tween.EASE_IN)
		twnFade.interpolate_property(sprStar,"modulate",
				Color(0,0,0,0),color_star,fade_time,
				Tween.TRANS_LINEAR,Tween.EASE_IN)
	twnCycle.interpolate_property(self,"rotation",
			cycle_rotations*2*PI,0,cycle_time,
			Tween.TRANS_LINEAR,Tween.EASE_OUT)
	twnRadius.start()
	twnRotation.start()
	twnFade.start()
	twnCycle.start()

func get_star_color(ID):
	if stars_achieved < stars_max:
		if ID >= stars_achieved:
			return color_unachieved - Color(0,0,0,0.7)
		else:
			return color_achieved
	else:
		return color_perfected

func _on_twnFade_tween_started(_object, _key):
	visible = true

func init_children():
	
	for child in get_children():
		child.queue_free()
	
	sprite_array = []
	for starID in stars_max:
		var sprStar = Sprite.new()
		sprStar.texture = stars_texture
		add_child(sprStar)
		sprite_array.append(sprStar)
	
	twnRotation = Tween.new()
	twnRotation.repeat = true
	add_child(twnRotation)
	
	twnFade = Tween.new()
	add_child(twnFade)
	
	twnCycle = Tween.new()
	twnCycle.repeat = true
	add_child(twnCycle)
	
	twnRadius = Tween.new()
	add_child(twnRadius)

func position_children():
	
	for sprite in sprite_array:
		sprite.position = radius_initial * Vector2.ONE.rotated(2*PI/stars_max)
	
