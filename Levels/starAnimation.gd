extends Node2D
tool
onready var sprite_array = [$sprStar0,$sprStar1,$sprStar2]

onready var twnRotation:Tween = $twnRotation
onready var twnFade:Tween = $twnFade
onready var twnCycle:Tween = $twnCycle
onready var twnRadius:Tween = $twnRadius

# Stars
var stars_max:int = 4
var stars_achieved:int = 2
var stars_texture:Texture setget set_stars_texture

# Rotation of individual stars
var rotation_time:float = 5

# Rotation of all stars around center
var cycle_time:float = 3
var cycle_rotations:float = 1

# Fade-in of stars
var fade_time:float = 2

# Radius of stars from center
var radius_time:float = 3
var radius_initial:float = 225
var radius_final:float = 85

# Colors for star types
var color_achieved:Color
var color_unachieved:Color
var color_perfected:Color

var tween_error

func set_stars_texture(texture:Texture):
	stars_texture = texture
	if not Engine.editor_hint:
		return
	for child in get_children():
		if "sprStar" in child.name:
			child.texture = texture

func _get_property_list() -> Array:
	return [
		{
			name = "Star Animation",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		
		{
			name = "stars_texture",
			type = TYPE_OBJECT,
			hint = PROPERTY_HINT_RESOURCE_TYPE,
			hint_string = "Texture",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		
		{
			name = "rotation_time",
			type = TYPE_REAL,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,10",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "cycle_time",
			type = TYPE_REAL,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,10",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "fade_time",
			type = TYPE_REAL,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,10",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		
		{
			name = "Radius",
			type = TYPE_NIL,
			hint_string = "radius_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "radius_initial",
			type = TYPE_REAL,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,1080",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "radius_final",
			type = TYPE_REAL,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,1080",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		
		{
			name = "Colors",
			type = TYPE_NIL,
			hint_string = "color_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "color_achieved",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "color_unachieved",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "color_perfected",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func _ready():
	if Engine.editor_hint:
		return
	start()

func start(given_stars_achieved = stars_achieved):
	visible = false
	stars_achieved = given_stars_achieved
	for ID in sprite_array.size():
		
		var sprStar = sprite_array[ID]
		var color_star = get_star_color(ID)
		
		var position_start = Vector2.ONE.rotated(ID*PI*2/3) * radius_initial
		var position_final = Vector2.ONE.rotated(ID*PI*2/3) * radius_final
		tween_error = twnRotation.interpolate_property(sprStar,"rotation",
				0,2*PI,rotation_time,
				Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
		tween_error = twnRadius.interpolate_property(sprStar,"position",
				position_start,position_final,radius_time,
				Tween.TRANS_LINEAR,Tween.EASE_IN)
		tween_error = twnFade.interpolate_property(sprStar,"modulate",
				Color(0,0,0,0),color_star,fade_time,
				Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween_error = twnCycle.interpolate_property(self,"rotation",
			cycle_rotations*2*PI,0,cycle_time,
			Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween_error = twnRadius.start()
	tween_error = twnRotation.start()
	tween_error = twnFade.start()
	tween_error = twnCycle.start()

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

#func init_children():
#
#	for child in get_children():
#		child.queue_free()
#
#	sprite_array = []
#	for starID in stars_max:
#		var sprStar = Sprite.new()
#		sprStar.texture = stars_texture
#		add_child(sprStar)
#		sprite_array.append(sprStar)
#
#	twnRotation = Tween.new()
#	twnRotation.repeat = true
#	add_child(twnRotation)
#
#	twnFade = Tween.new()
#	add_child(twnFade)
#
#	twnCycle = Tween.new()
#	twnCycle.repeat = true
#	add_child(twnCycle)
#
#	twnRadius = Tween.new()
#	add_child(twnRadius)
#
#func position_children():
#
#	for sprite in sprite_array:
#		sprite.position = radius_initial * Vector2.ONE.rotated(2*PI/stars_max)
	
