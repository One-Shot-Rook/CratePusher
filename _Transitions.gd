extends Node

var tweenError

func transitionScene(scenePath:String,stopMusic:bool = false):
	if stopMusic:
		Music.stopTrack()
	tweenError = $twnChangeScene.connect("tween_all_completed",self,"changeScene",[scenePath],CONNECT_ONESHOT)
	$twnChangeScene.interpolate_property(
			$modFade,"color",
			Color(1,1,1), Color(0,0,0),
			1,Tween.TRANS_QUAD,Tween.EASE_OUT
	)
	$twnChangeScene.start()

func changeScene(scenePath:String):
	var _change_scene_error = get_tree().change_scene(scenePath)
	revealScene()

func revealScene():
	$twnChangeScene.interpolate_property(
			$modFade,"color",
			Color(0,0,0), Color(1,1,1),
			0.3,Tween.TRANS_QUAD,Tween.EASE_IN
	)
	$twnChangeScene.start()
