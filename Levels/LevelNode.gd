extends Node2D

func _ready():
	startLevel()

func startLevel(level_name=LevelData.current_level):
	for childTileMap in get_children():
		childTileMap.free()
	LevelData.set_current_level(level_name)
	var loadpath = "res://Levels/World" + str(SaveData.get_current_world()) + "/" + level_name + ".tscn"
	add_child(load(loadpath).instance())


func _on_btnReset_pressed():
	startLevel()


func _on_btnMenu_pressed():
	Transition.transitionScene("res://MenuScene.tscn",true)
