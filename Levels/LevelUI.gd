extends Control

var LevelComplete_load = load("res://Levels/LevelComplete.tscn")

func _ready():
	GameInput.connect("key_inputted",$Hint,"hide")

func update_level_name():
	$bottomBar/labLevelName.text = LevelData.current_level

func update_move_count(move_count):
	$bottomBar/labMoveCount.text = str(move_count)

func complete_level(move_count,stars):
	var LevelComplete = LevelComplete_load.instance()
	$Z_IndexAdjuster/levelComplete.add_child(LevelComplete)
	LevelComplete.update_ui(move_count,stars)
