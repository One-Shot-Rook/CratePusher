extends Control

export var dimColor:Color

func _ready():
	for texStar in $hboxStars.get_children():
		if int(texStar.name[-1]) > LevelData.stars:
			texStar.modulate = dimColor
	
	SaveData.updateLevelStars(LevelData.currentLevel, LevelData.stars)
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
