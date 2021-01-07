extends Node

var levelData = {
	"level01":{
		"moves":[5,6,7,9]
	},
	"level04":{
		"moves":[12,14,17,21]
	},
	"level10":{
		"moves":[23,24,27,29]
	},
	"level11":{
		"moves":[19,20,24,28]
	},
	"level7":{
		"moves":[28,29,32,35]
	}
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
