extends Node

var levelData = {
	"level01":{
		"moves":[5,7,9]
	},
	"level04":{
		"moves":[12,14,19]
	},
	"level10":{
		"moves":[23,25,27]
	},
	"level7":{
		"moves":[28,31,35]
	}
}

var levelComplete:bool = false

var currentLevel:String
var moveCount:int
var stars:int = 3

func tryCompleteLevel():
	if not levelComplete:
		return
	get_tree().call_group("level","endLevel")

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
	stars = 3
	for moveCriteria in levelData[currentLevel]["moves"]:
		if moveCount <= moveCriteria:
			return stars
		stars -= 1
	return stars
