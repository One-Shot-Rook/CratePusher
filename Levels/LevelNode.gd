extends Node2D

func _ready():
	startLevel()

func startLevel(levelName=LevelData.current_level):
	for childTileMap in get_children():
		childTileMap.free()
	LevelData.set_current_level(levelName)
	print(levelName.split("-")[1])
	var loadpath = "res://Levels/World" + str(SaveData.get_current_world()) + "/" + "level" + levelName.split("-")[1] + ".tscn"
	add_child(load(loadpath).instance())


func _on_btnReset_pressed():
	startLevel()


func _on_btnMenu_pressed():
	Transition.transitionScene("res://MenuScene.tscn",true)
