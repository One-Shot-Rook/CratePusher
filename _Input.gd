extends Node

signal direction_inputted(direction)

const drag_distance := 300

var mouse_start:Vector2 = Vector2.ZERO

func _unhandled_input(event):
	
	if event is InputEventScreenTouch:
		
		if event.pressed:
			
			if mouse_start == Vector2.ZERO:
				
				mouse_start = event.position
			
		else:
			var rel_vector = event.position - mouse_start
			if rel_vector.length() >= drag_distance:
				var angle = rel_vector.angle()
				angle = stepify(angle,PI/2)
				var input_vector = Vector2(cos(angle),sin(angle))
				mouse_start = Vector2.ZERO
				emit_signal("direction_inputted",input_vector)
