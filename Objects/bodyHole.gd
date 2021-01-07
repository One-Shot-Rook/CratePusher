class_name Hole
extends KinematicBody2D

export var is_bottomless:bool = false
var is_filled = false

func get_class() -> String: return "Hole"

func _ready():
	if is_bottomless:
		$sprite.texture = load("res://Assets/Sprites/img_hole_endless.png")
	else:
		$sprite.texture = load("res://Assets/Sprites/img_hole_fill.png")

func fill_with(resource_path):
	if is_bottomless or is_filled:
		return
	is_filled = true
	$sprSunk.texture = load(resource_path)
	

