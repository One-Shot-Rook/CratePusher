extends Node2D

var origin = Vector2(0,0) # point rotated around of
var total_stars = 0 # number of stars achieved in level

func start(value=4):
	total_stars = value
	for child in get_children():
		if "Sprite" in child.name:
			var star_number = int(child.name.trim_prefix("Sprite"))
			if star_number > total_stars:
				child.visible = false
			child.position = rot_matrix(star_number) * Vector2(-550,50)
			child.custom_animate(origin)

func rot_matrix(value) -> Transform2D:
	return Transform2D(float(value*PI*2/total_stars), origin)

