extends Node2D

func startLevel(pathString):
	print("PRESSED ",pathString)
	for childTileMap in get_children():
		childTileMap.free()
	add_child(load("res://Levels/"+pathString).instance())
