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
	"1-16":{
		"moves":[23,24,27,31]
	},
	"1-17":{
		"moves":[10,11,13,16]
	},
	"1-18":{
		"moves":[13,14,17,20]
	},
	"1-19":{
		"moves":[7,8,10,12]
	},
	"1-20":{
		"moves":[12,13,15,19]
	},
	"1-21":{
		"moves":[9,10,13,17]
	},
}

var level_complete:bool = false

var current_level:String
var levels_per_world := 15
var move_count:int
var stars:int = 4
var star_requirements = {}

func set_star_requirements(new_star_requirements):
	star_requirements = new_star_requirements

func set_current_level(levelName):
	level_complete = false
	current_level = levelName

func set_level_next():
	var nextLvlName = int(current_level.split("-")[1])+1
	print(SaveData.current_world)
	if nextLvlName > 15:
		Transition.transitionScene("res://MenuScene.tscn",true)
	if nextLvlName < 10:
		nextLvlName = "0" + str(nextLvlName)
	nextLvlName = str(SaveData.current_world) + "-" + str(nextLvlName)
	if SaveData.levelProgress.has(nextLvlName):
		current_level = nextLvlName

func set_level_prev():
	var nextLvlName = int(current_level.split("-")[1])-1
	print(SaveData.current_world)
	if nextLvlName < 1:
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
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"UI","updateUI")

# increment move_count
func incrementMoveCount():
	move_count += 1
	updateCurrentStars()
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"UI","updateUI")

func updateCurrentStars():
	if not level_data.has(current_level):
		return
	if move_count <= star_requirements["flawless"]:
		stars = 4
	elif move_count <= star_requirements["3 star"]:
		stars = 3
	elif move_count <= star_requirements["2 star"]:
		stars = 2
	elif move_count <= star_requirements["1 star"]:
		stars = 1
	else:
		stars = 0
