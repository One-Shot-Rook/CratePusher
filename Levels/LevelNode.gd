extends Node2D

func _ready():
	startLevel()

func startLevel(level_name=LevelData.current_level):
	for child_TileMap in get_children():
		child_TileMap.free()
	LevelData.setCurrentLevel(level_name)
	add_child(load("res://Levels/"+level_name+".tscn").instance())


func _on_btnReset_pressed():
	startLevel()


func _on_btnMenu_pressed():
	Transition.transitionScene("res://MenuScene.tscn",true)
