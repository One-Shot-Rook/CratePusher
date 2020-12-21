extends Control

var LevelComplete_load = load("res://Levels/LevelComplete.tscn")

func updateUI():
	$bottomBar/labMoveCount.text = "Moves: " + str(LevelData.moveCount)
	$bottomBar/labStars.text = "Stars: " + str(LevelData.stars)

func endLevel():
	var LevelComplete = LevelComplete_load.instance()
	add_child(LevelComplete)
