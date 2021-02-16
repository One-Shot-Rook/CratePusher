class_name GameObject, "res://icons/GameObject.svg"
extends Node2D

var Level = null
var save_variables:PoolStringArray
var tile_size := 96
var snap = false setget editor_snap
var animate = false setget set_animate

var is_detectable := true # Can other objects get our position

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

func set_animate(new_value):
	animate = new_value

func editor_snap(_value):
	snap_to_tile()

func get_save_data():
	var save_data = {}
	for variable_name in save_variables:
		save_data[variable_name] = get(variable_name)
	return save_data

func set_save_data(save_data):
	for variable_name in save_data:
		set(variable_name,save_data[variable_name])

func snap_to_tile(_blank=false) -> void:
	var shifted_position = position - tile_size * Vector2.ONE / 2
	position = Vector2( stepify(shifted_position[0],tile_size), stepify(shifted_position[1],tile_size) )
	position += tile_size * Vector2.ONE / 2
