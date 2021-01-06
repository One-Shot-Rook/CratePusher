extends Node

var tweenError

func transitionScene(scenePath:String,stopMusic:bool = false):
	if stopMusic:
		Music.stopTrack()
	tweenError = $twnChangeScene.connect("tween_all_completed",self,"changeScene",[scenePath],CONNECT_ONESHOT)
	$twnChangeScene.interpolate_property(
		$modFade,"color",
		Color(1,1,1), Color(0,0,0),
		1,Tween.TRANS_CUBIC,Tween.EASE_IN
	)
	$twnChangeScene.start()

func changeScene(scenePath:String):
	var _change_scene_error = get_tree().change_scene(scenePath)
	revealScene()

func revealScene():
	$modFade.color = Color.white
