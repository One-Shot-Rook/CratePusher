extends Control

var LevelComplete_load = load("res://Levels/LevelComplete.tscn")

func updateUI():
	$bottomBar/labMoveCount.text = str(LevelData.moveCount)
	$bottomBar/labStars.text = ""
	for _star in range(LevelData.stars):
		$bottomBar/labStars.text += "* "
	$topBar/labLevelName.text = str(SaveData.get_currentWorld()) + "-" + LevelData.currentLevel.right(5)

func endLevel():
	var LevelComplete = LevelComplete_load.instance()
	$Z_IndexAdjuster/levelComplete.add_child(LevelComplete)
