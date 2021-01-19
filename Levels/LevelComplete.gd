extends Control

export var dimColor:Color

func _ready():
	#$texChip.texture = load("res://Assets/UI/img_chip_" + str(LevelData.stars) + ".png")
	$starAnimation.start(LevelData.stars)
	SaveData.updateLevelStars(LevelData.current_level, LevelData.stars)
	get_tree().call_group("UI","updateUI")

func _on_btnContinue_pressed():
	LevelData.set_level_next()
	queue_free()
	get_tree().call_group("level","startLevel")


func _on_btnReplay_pressed():
	queue_free()
	get_tree().call_group("level","startLevel")


func _on_btnMenu_pressed():
	Transition.transitionScene("res://MenuScene.tscn",true)
