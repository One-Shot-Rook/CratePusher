class_name Hole, "res://icons/Hole.svg"
tool
extends Node2D

export var is_bottomless:bool = false
var is_filled = false

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

func get_class() -> String: return "Hole"

func _ready():
	if is_bottomless:
		$sprite.texture = load("res://Assets/Sprites/svg_hole_bottomless.svg")
	else:
		$sprite.texture = load("res://Assets/Sprites/svg_hole_fillable.svg")

func fill_with(resource_path):
	if is_bottomless or is_filled:
		return
	is_filled = true
	$sprSunk.texture = load(resource_path)
	

