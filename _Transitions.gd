extends Node

var _tween_error
var _change_scene_error

enum MetaData{DEFAULT,MENU_NEW_WORLD,MENU_LEVELS}
var meta_data:int = MetaData.DEFAULT

func _fade_out(scenePath:String,stopMusic:bool = false):
	get_tree().get_root().gui_disable_input = true
	if stopMusic:
		Music.stopTrack()
	_tween_error = $twnChangeScene.connect("tween_all_completed",self,"_switch_scene",[scenePath],CONNECT_ONESHOT)
	$twnChangeScene.interpolate_property(
			$modFade,"color",
			Color(1,1,1), Color(0,0,0),
			1,Tween.TRANS_QUAD,Tween.EASE_OUT
	)
	$twnChangeScene.start()

func _switch_scene(scenePath:String):
	_change_scene_error = get_tree().change_scene(scenePath)
	_fade_in()

func _fade_in():
	get_tree().get_root().gui_disable_input = false
	$twnChangeScene.interpolate_property(
			$modFade,"color",
			Color(0,0,0), Color(1,1,1),
			0.3,Tween.TRANS_QUAD,Tween.EASE_IN
	)
	$twnChangeScene.start()



func goto_main_scene():
	meta_data = MetaData.DEFAULT
	_fade_out("res://Levels/Main.tscn",true)

func goto_menu_scene():
	meta_data = MetaData.DEFAULT
	_fade_out("res://MenuScene.tscn",true)

func goto_levels_scene():
	meta_data = MetaData.MENU_LEVELS
	_fade_out("res://MenuScene.tscn",true)

func unlock_new_world():
	meta_data = MetaData.MENU_NEW_WORLD
	_fade_out("res://MenuScene.tscn",true)



