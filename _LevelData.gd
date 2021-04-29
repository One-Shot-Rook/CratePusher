extends Node

var level_complete:bool = false

var current_level:String
var levels_per_world := 11

func set_current_level(levelName):
	level_complete = false
	current_level = levelName

func set_level_next():
	var nextLvlName = int(current_level.split("-")[1])+1
	#print(SaveData.current_world)
	if nextLvlName > levels_per_world:
		Transition.unlock_new_world()
	if nextLvlName < 10:
		nextLvlName = "0" + str(nextLvlName)
	nextLvlName = str(SaveData.current_world) + "-" + str(nextLvlName)
	if SaveData.levelProgress.has(nextLvlName):
		current_level = nextLvlName

func set_level_prev():
	var nextLvlName = int(current_level.split("-")[1])-1
	#print(SaveData.current_world)
	if nextLvlName < 1:
		Transition.goto_levels_scene()
	if nextLvlName < 10:
		nextLvlName = "0" + str(nextLvlName)
	nextLvlName = str(SaveData.current_world) + "-" + str(nextLvlName)
	if SaveData.levelProgress.has(nextLvlName):
		current_level = nextLvlName
