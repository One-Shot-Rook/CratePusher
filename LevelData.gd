extends Node

var levelData = {
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

var levelComplete:bool = false

var currentLevel:String
var moveCount:int
var stars:int = 4


func setCurrentLevel(levelName):
	levelComplete = false
	currentLevel = levelName

func set_level_next():
	var nextLvlName = int(currentLevel.trim_prefix("level").trim_prefix("0"))+1
	if nextLvlName < 10:
		nextLvlName = "0" + str(nextLvlName)
	nextLvlName = "level" + str(nextLvlName)
	if SaveData.levelProgress.has(nextLvlName):
		currentLevel = nextLvlName

# reset moveCount
func initialiseMoveCount():
	moveCount = 0
	updateCurrentStars()
	get_tree().call_group("UI","updateUI")

# increment moveCount
func incrementMoveCount():
	moveCount += 1
	updateCurrentStars()
	get_tree().call_group("UI","updateUI")

func updateCurrentStars():
	if not levelData.has(currentLevel):
		return
	stars = 4
	for moveCriteria in levelData[currentLevel]["moves"]:
		if moveCount <= moveCriteria:
			return stars
		stars -= 1
	return stars
