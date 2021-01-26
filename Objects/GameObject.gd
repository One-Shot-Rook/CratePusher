class_name GameObject, "res://icons/GameObject.svg"
extends Node2D

var Level

func _enter_tree():
	Level = get_tile_map()

func get_tile_map():
	var pot_level = get_parent()
	if pot_level.get_class() == "TileMap":
		return pot_level
	return null

func snap_to_tile(_blank=false) -> void:
	var shifted_position = position - 16*Vector2.ONE
	position = Vector2( stepify(shifted_position[0],Level.cell_size.x), stepify(shifted_position[1],Level.cell_size.y) )
	position += 0.5 * Level.cell_size
