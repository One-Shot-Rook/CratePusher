extends Control

var changing = false
var tweenError

onready var twnPanel = get_parent().get_node("twnPanel")

func _ready():
	updateUI()

func updateUI():
	$worldLabel.text = "World - " + str(SaveData.get_current_world())

func levelPressed(levelName:String):
	print("pressed")
	if changing:
		return
	$btnBack.disabled = true
	changing = true
	Transition.transitionScene("res://Levels/Main.tscn",true)
	LevelData.setCurrentLevel(levelName)


func _on_btnRight_pressed():
	get_parent().buttonWasPressed()
	if SaveData.set_current_world(SaveData.get_current_world() + 1):
		twnPanel.interpolate_property(
			$hboxWorlds, 
			"rect_position", 
			$hboxWorlds.rect_position, 
			Vector2(210, 240) + Vector2((SaveData.get_current_world()-1)*-1080,0),
			0.5, 
			Tween.TRANS_CUBIC, 
			Tween.EASE_IN_OUT
		)
		twnPanel.start()
	get_tree().call_group("level_select","updateUI")


func _on_btnLeft_pressed():
	get_parent().buttonWasPressed()
	if SaveData.set_current_world(SaveData.get_current_world() - 1):
		twnPanel.interpolate_property(
			$hboxWorlds, 
			"rect_position", 
			$hboxWorlds.rect_position, 
			Vector2(210, 240) + Vector2((SaveData.get_current_world()-1)*-1080,0),
			0.5, 
			Tween.TRANS_CUBIC, 
			Tween.EASE_IN_OUT
		)
		twnPanel.start()
	get_tree().call_group("level_select","updateUI")
