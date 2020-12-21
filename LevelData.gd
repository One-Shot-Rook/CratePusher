extends Node

var levelData = {
	"level0":{
		"moves":[23,25,27]
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
