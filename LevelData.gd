extends Node

var level_data = {
	"level01":{
		"moves":[6,7,8,10]
	},
	"level02":{
		"moves":[5,6,8,10]
	},
	"level03":{
		"moves":[6,7,8,10]
	},
	"level04":{
		"moves":[6,7,9,11]
	},
	"level05":{
		"moves":[7,8,10,12]
	},
	"level06":{
		"moves":[19,21,24,27]
	},
	"level07":{
		"moves":[12,13,15,18]
	},
	"level08":{
		"moves":[19,20,22,25]
	},
	"level09":{
		"moves":[13,14,16,19]
	},
	"level10":{
		"moves":[9,10,12,14]
	},
	"level11":{
		"moves":[9,10,12,14]
	},
	"level12":{
		"moves":[7,8,10,12]
	},
}

var level_complete:bool = false

var current_level:String
var current_world := "1"
var move_count:int
var stars:int = 4


func set_current_level(levelName):
	level_complete = false
	current_level = levelName

func set_level_next():
	var nextLvlName = int(current_level.trim_prefix("level").trim_prefix("0"))+1
	if nextLvlName < 10:
		nextLvlName = "0" + str(nextLvlName)
	nextLvlName = "level" + str(nextLvlName)
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
