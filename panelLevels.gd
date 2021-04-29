extends Control

var changing = false
var tweenError

onready var twnPanel = get_parent().get_node("twnPanel")

func _ready():
	updateUI()

func updateUI():
	$worldLabel.text = "World - " + str(SaveData.get_current_world())
	$hboxWorlds.rect_position = Vector2(210, 240) + Vector2((SaveData.current_world-1)*-1080,0)
	$btnLeft.visible = true
	$btnRight.visible = true
	if SaveData.is_world_locked():
		$world_lock.visible = true
		$world_lock/Label.text = String(24 * (SaveData.get_current_world() - 1)) + " stars needed to \nunlock world"
	else:
		$world_lock.visible = false
	if SaveData.current_world == 1:
		$btnLeft.visible = false
	elif SaveData.current_world == SaveData.maxWorlds:
		$btnRight.visible = false
	$starAmount.text = String(SaveData.achieved_stars) + "/132 Stars" 

func levelPressed(levelName:String):
	if changing:
		return
	$btnBack.disabled = true
	changing = true
	LevelData.set_current_level(levelName)
	Transition.goto_main_scene()



func _on_btn_pressed(world_change:int):
	Music.button_was_pressed()
	move_to_world(world_change)
	updateUI()

func move_to_world(world_change:int):
	var new_world = SaveData.current_world + world_change
	if not SaveData.set_current_world(new_world):
		return
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
	get_parent().update_world_ui()
	get_tree().call_group("level_select","updateUI")
	SaveData.saveGame()
