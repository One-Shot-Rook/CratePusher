extends Panel

var changing = false
var tweenError

func levelPressed(levelName:String):
	if changing:
		return
	$btnBack.disabled = true
	changing = true
	tweenError = $twnBeginLevel.connect("tween_all_completed",self,"goToLevel",[],CONNECT_ONESHOT)
	$twnBeginLevel.interpolate_property(
		$modBeginLevel,"color",
		Color(1,1,1), Color(0,0,0),
		1,Tween.TRANS_CUBIC,Tween.EASE_IN
	)
	$twnBeginLevel.start()
	Music.stopTrack()
	LevelData.setCurrentLevel(levelName)

func goToLevel():
	var _ERROR_CODE = get_tree().change_scene("res://Levels/Main.tscn")
