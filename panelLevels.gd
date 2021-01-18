extends Control

var changing = false
var tweenError

onready var twnPanel = get_parent().get_node("twnPanel")

func _ready():
	updateUI()

func updateUI():
	$worldLabel.text = "World - " + str(SaveData.get_current_world())
	$hboxWorlds.rect_position = Vector2(210, 240) + Vector2((SaveData.current_world-1)*-1080,0)

func levelPressed(levelName:String):
	if changing:
		return
	$btnBack.disabled = true
	changing = true
	Transition.transitionScene("res://Levels/Main.tscn",true)
	LevelData.set_current_level(levelName)



func _on_btn_pressed(world_change:int):
	get_parent().button_was_pressed()
	if SaveData.set_current_world(SaveData.current_world + world_change):
		twnPanel.interpolate_property(
			$hboxWorlds, 
			"rect_position", 
			$hboxWorlds.rect_position, 
			Vector2(210, 240) + Vector2((SaveData.current_world-1)*-1080,0),
			0.5, 
			Tween.TRANS_CUBIC, 
			Tween.EASE_IN_OUT
		)
		twnPanel.start()
	get_tree().call_group("level_select","updateUI")
