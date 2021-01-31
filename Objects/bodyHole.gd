class_name Hole, "res://icons/Hole.svg"
tool
extends GameObject

export var is_bottomless:bool = false

var is_filled = false setget set_is_filled

func _init():
	save_variables = PoolStringArray(["is_filled"])

func _get_property_list() -> Array:
	return [
		{
			name = "Hole",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "is_bottomless",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func set_is_filled(new_value):
	is_filled = new_value
	$sprSunk.visible = is_filled

func get_class() -> String: return "Hole"



func _ready():
	if is_bottomless:
		$sprite.texture = load("res://Assets/Sprites/svg_hole_bottomless.svg")
	else:
		$sprite.texture = load("res://Assets/Sprites/svg_hole_fillable.svg")

func fill_with(texture):
	if is_bottomless or is_filled:
		return
	$sprSunk.texture = texture
	set_is_filled(true)

