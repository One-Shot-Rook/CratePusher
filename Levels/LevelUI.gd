extends Control

var LevelComplete_load = load("res://Levels/LevelComplete.tscn")

onready var star_nodes = [
	$bottomBar/Stars/star1,
	$bottomBar/Stars/star2,
	$bottomBar/Stars/star3,
	]

func update_level_name():
	$bottomBar/labLevelName.text = LevelData.current_level

func update_move_count(move_count):
	$bottomBar/labMoveCount.text = str(move_count)

func update_stars(stars):
	#print(stars)
	for star_node in star_nodes:
		star_node.update_ui(stars)

func complete_level(move_count,stars):
	var LevelComplete = LevelComplete_load.instance()
	$Z_IndexAdjuster/levelComplete.add_child(LevelComplete)
	LevelComplete.update_ui(move_count,stars)
