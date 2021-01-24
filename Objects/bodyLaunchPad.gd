class_name LaunchPad, "res://icons/LaunchPad.svg"
tool
extends Node2D

export(NodePath) var path_sprBack
onready var sprBack:Sprite
export(NodePath) var path_aniMiddle
onready var aniMiddle:AnimatedSprite

export var primary_color:Color setget set_primary_color
export var secondary_color:Color setget set_secondary_color
enum Direction{UP,RIGHT,DOWN,LEFT}
export(Direction) var direction setget set_direction

var direction_vectors = [Vector2.UP,Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT]

func _get_property_list() -> Array:
	return [
		{
			name = "LaunchPad",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "direction",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Up,Right,Down,Left",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "primary_color",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "secondary_color",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func set_primary_color(color):
	primary_color = color
	update_ui()

func set_secondary_color(color):
	secondary_color = color
	update_ui()

func set_direction(new_direction):
	direction = new_direction
	update_ui()

func get_class() -> String: return "LaunchPad"

func update_ui():
	if Engine.editor_hint:
		for child in get_children():
			if "Middle" in child.name:
				child.modulate = secondary_color
			elif "Back" in child.name:
				child.modulate = primary_color
		rotation_degrees = direction * 90

func get_direction_vector():
	return direction_vectors[direction]
