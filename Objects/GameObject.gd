class_name GameObject, "res://icons/GameObject.svg"
extends Node2D

var Level
var tile_size := 96
var snap = false setget editor_snap

func _get_property_list():
	return [
		{
			name = "GameObject",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "snap",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
	]

func editor_snap(_value):
	snap_to_tile()

func _enter_tree():
	Level = get_tile_map()

func get_tile_map():
	var pot_level = get_parent()
	if pot_level.get_class() == "TileMap":
		return pot_level
	return null

func snap_to_tile(_blank=false) -> void:
	var shifted_position = position - tile_size * Vector2.ONE / 2
	position = Vector2( stepify(shifted_position[0],tile_size), stepify(shifted_position[1],tile_size) )
	position += tile_size * Vector2.ONE / 2
