class_name Laser
tool
extends GameObject

var hit_mark:Vector2
var line_thickness = 5
var circle_thickness = 16

func _get_property_list() -> Array:
	return [
		{
			name = "Laser",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func get_class() -> String: return "Laser"

func _physics_process(delta):
	
	var world_state = get_world_2d().direct_space_state
	var result = world_state.intersect_ray(
			position, position + (Vector2(1,0) * 9999).rotated(rotation), [self])
	if result:
		hit_mark = result.position - position
		$Particles2D.position = hit_mark.rotated(-rotation)
		update()

func _draw():
	
	draw_line(Vector2.ZERO,hit_mark.rotated(-rotation),Color.red,line_thickness + rand_range(-1,1))
	draw_circle(hit_mark.rotated(-rotation),circle_thickness + rand_range(-2,2),Color.red)
