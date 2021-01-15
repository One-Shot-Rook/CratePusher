extends Control

var LevelComplete_load = load("res://Levels/LevelComplete.tscn")

func updateUI():
	$bottomBar/labMoveCount.text = str(LevelData.moveCount)
	$bottomBar/labStars.text = ""
	for _star in range(LevelData.stars):
		$bottomBar/labStars.text += "* "

func endLevel():
	var LevelComplete = LevelComplete_load.instance()
	$Z_IndexAdjuster/levelComplete.add_child(LevelComplete)
