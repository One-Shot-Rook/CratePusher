class_name LaunchPad
tool
extends Node2D

export var primary_color:Color setget set_primary_color
export var secondary_color:Color setget set_secondary_color
enum Direction{UP,RIGHT,DOWN,LEFT}
export(Direction) var direction setget set_direction

var direction_vectors = [Vector2.UP,Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT]

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
		$sprite_1.modulate = primary_color
		$sprite_2.modulate = secondary_color
		rotation_degrees = direction * 90

func get_direction_vector():
	return direction_vectors[direction]
