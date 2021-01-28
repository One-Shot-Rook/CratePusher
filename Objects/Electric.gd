class_name Electric
tool
extends Node2D

export var animate:bool = true
export var starting_position:Vector2
export var ending_position:Vector2
export(int,2,9999) var points:int setget set_points
export(float,0,300) var line_width:float = 4.0
export(float,0,1) var width
export(int,0,240) var fps:int = 60 setget set_fps
export(Curve) var curve:Curve

var draw_points:PoolVector2Array
var rng = RandomNumberGenerator.new()
var delta_sum:float = 0.0
var delta_limit:float = 0.0

func set_points(new_points):
	points = new_points

func set_fps(new_fps):
	fps = new_fps
	delta_limit = 1/float(fps)

func generate_draw_points():
	draw_points = PoolVector2Array()
	var relative_vector = ending_position - starting_position
	var tangent_vector:Vector2 = relative_vector.tangent().normalized()
	for point in points:
		var normal_position = relative_vector * point / float(points-1)
		if point == 0 or point == points -1:
			draw_points.append(normal_position)
		else:
			#tangent_vector = (tangent_vector).rotated(PI)
			draw_points.append(
				normal_position + 
				tangent_vector * rng.randf_range(-1,1) * relative_vector.length() * 
				width * curve.interpolate(point / float(points-1))
			)
	#print(relative_vector,tangent_vector)

func _draw():
	
	for point_index in draw_points.size()-1:
		draw_line(draw_points[point_index],draw_points[point_index+1],Color.white,line_width)
		draw_circle(draw_points[point_index],line_width/2.0,Color.white)

func _process(delta):
	if not animate:
		return
	delta_sum += delta
	if delta_sum >= delta_limit:
		delta_sum -= delta_limit
		if delta_sum >= delta_limit:
			delta_sum = 0
		generate_draw_points()
		update()
