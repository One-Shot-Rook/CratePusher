extends Control

var LevelComplete_load = load("res://Levels/LevelComplete.tscn")

func updateUI():
	$bottomBar/labMoveCount.text = str(LevelData.move_count)
	$bottomBar/labStars.text = ""
	for _star in range(LevelData.stars):
		$bottomBar/labStars.text += "* "
	$topBar/labLevelName.text = str(SaveData.get_current_world()) + "-" + LevelData.current_level.right(5)

func endLevel():
	var LevelComplete = LevelComplete_load.instance()
	$Z_IndexAdjuster/levelComplete.add_child(LevelComplete)
