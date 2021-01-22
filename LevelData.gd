extends Node

var level_data = {
	"1-01":{
		"moves":[6,7,8,10]
	},
	"1-02":{
		"moves":[5,6,8,10]
	},
	"1-03":{
		"moves":[6,7,8,10]
	},
	"1-04":{
		"moves":[6,7,9,11]
	},
	"1-05":{
		"moves":[7,8,10,12]
	},
	"1-06":{
		"moves":[19,21,24,27]
	},
	"1-07":{
		"moves":[12,13,15,18]
	},
	"1-08":{
		"moves":[19,20,22,25]
	},
	"1-09":{
		"moves":[13,14,16,19]
	},
	"1-10":{
		"moves":[9,10,12,14]
	},
	"1-11":{
		"moves":[9,10,12,14]
	},
	"1-12":{
		"moves":[7,8,10,12]
	},
}

var level_complete:bool = false

var current_level:String
var levels_per_world := 15
var move_count:int
var stars:int = 4


func set_current_level(levelName):
	level_complete = false
	current_level = levelName

func set_level_next():
	var nextLvlName = int(current_level.split("-")[1])+1
	print(SaveData.current_world)
	if nextLvlName - int(SaveData.current_world-1)*levels_per_world > 15:
		Transition.transitionScene("res://MenuScene.tscn",true)
	if nextLvlName < 10:
		nextLvlName = "0" + str(nextLvlName)
	nextLvlName = str(SaveData.current_world) + "-" + str(nextLvlName)
	if SaveData.levelProgress.has(nextLvlName):
		current_level = nextLvlName

func set_level_prev():
	var nextLvlName = int(current_level.split("-")[1])-1
	print(SaveData.current_world)
	if nextLvlName - int(SaveData.current_world-1)*levels_per_world < 1:
		Transition.transitionScene("res://MenuScene.tscn",true)
	if nextLvlName < 10:
		nextLvlName = "0" + str(nextLvlName)
	nextLvlName = str(SaveData.current_world) + "-" + str(nextLvlName)
	if SaveData.levelProgress.has(nextLvlName):
		current_level = nextLvlName
# reset move_count
func initialiseMoveCount():
	move_count = 0
	updateCurrentStars()
	get_tree().call_group("UI","updateUI")

# increment move_count
func incrementMoveCount():
	move_count += 1
	updateCurrentStars()
	get_tree().call_group("UI","updateUI")

func updateCurrentStars():
	if not level_data.has(current_level):
		return
	stars = 4
	for move_criteria in level_data[current_level]["moves"]:
		if move_count <= move_criteria:
			return stars
		stars -= 1
	return stars
