extends Sprite

var origin
var vector_distance_from_origin = Vector2(0,0)
var radius = 0
var phi:float = 0 #in radians

func custom_animate(value):
	origin = value
	vector_distance_from_origin = origin - position
	phi = atan2(vector_distance_from_origin.y,vector_distance_from_origin.x)
	radius = vector_distance_from_origin.length()

func _process(delta):
	if radius == 0:
		return
	radius *= 0.995
	if radius < 85:
		radius = 85
	phi += delta*2*PI/5
	if phi > 2*PI:
		phi -= 2*PI
	rotation = -phi/2
	position = Vector2(radius * cos(phi), radius * sin(phi)) + origin

