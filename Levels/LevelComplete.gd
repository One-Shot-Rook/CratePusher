extends Control

export var dimColor:Color

func _ready():
	for texStar in $hboxStars.get_children():
		if int(texStar.name[-1]) > LevelData.stars:
			texStar.modulate = dimColor
	
	SaveData.updateLevelStars(LevelData.currentLevel, LevelData.stars)

func _on_btnContinue_pressed():
	queue_free()
	get_tree().call_group("level","startLevel")
