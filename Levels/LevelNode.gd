extends Node2D

func _ready():
	startLevel()

func startLevel(levelName=LevelData.currentLevel):
	for childTileMap in get_children():
		childTileMap.free()
	LevelData.setCurrentLevel(levelName)
	var loadpath = "res://Levels/World" + str(SaveData.get_currentWorld()) + "/" + levelName + ".tscn"
	add_child(load(loadpath).instance())


func _on_btnReset_pressed():
	startLevel()


func _on_btnMenu_pressed():
	Transition.transitionScene("res://MenuScene.tscn",true)
