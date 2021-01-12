class_name LaunchPad
tool
extends Node2D

export var primary_color:Color setget set_primary_color
export var secondary_color:Color setget set_secondary_color




func set_primary_color(color):
	primary_color = color
	update_ui()

func set_secondary_color(color):
	secondary_color = color
	update_ui()

func get_class() -> String: return "LaunchPad"

func update_ui():
	$sprite_1.modulate = primary_color
	$sprite_2.modulate = secondary_color

func _ready():
	pass
	

