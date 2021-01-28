extends Control

export var dimColor:Color

func _ready():
	#$texChip.texture = load("res://Assets/UI/img_chip_" + str(LevelData.stars) + ".png")
	get_tree().call_group("UI","updateUI")

func update_ui(_move_count,stars):
	$starAnimation.start(stars)

func _on_btnContinue_pressed():
	LevelData.set_level_next()
	queue_free()
	get_tree().call_group("level","startLevel")


func _on_btnReplay_pressed():
	queue_free()
	get_tree().call_group("level","startLevel")


func _on_btnMenu_pressed():
	Transition.goto_levels_scene()
