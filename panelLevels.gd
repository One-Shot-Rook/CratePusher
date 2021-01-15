extends Control

var changing = false
var tweenError

func levelPressed(levelName:String):
	if changing:
		return
	$btnBack.disabled = true
	changing = true
	Transition.transitionScene("res://Levels/Main.tscn",true)
	LevelData.setCurrentLevel(levelName)
