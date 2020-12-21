extends Node2D

func _ready():
	startLevel()

func startLevel(levelName=LevelData.currentLevel):
	for childTileMap in get_children():
		childTileMap.free()
	LevelData.setCurrentLevel(levelName)
	add_child(load("res://Levels/"+levelName+".tscn").instance())
