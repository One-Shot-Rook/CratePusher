extends Node2D

func _ready():
	Globals.initialseObjectStates(get_tree().get_nodes_in_group("object"))
