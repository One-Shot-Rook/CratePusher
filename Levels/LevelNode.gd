extends Node2D

var current_level_node:GameLevel

func _ready():
	startLevel()

func startLevel(is_first=true,level_name=LevelData.current_level):
	if current_level_node:
		current_level_node.free()
	LevelData.set_current_level(level_name)
	#print(level_name.split("-")[1])
	var loadpath = "res://Levels/World" + str(SaveData.get_current_world()) + "/" + "level" + level_name.split("-")[1] + ".tscn"
	var levelXX:GameLevel = load(loadpath).instance()
	levelXX.level_name = level_name
	current_level_node = levelXX
	current_level_node.show_behind_parent = true
	add_child(current_level_node)
	
	center_level()
	if is_first:
		check_for_popup()

func center_level():
	
	var tile_map_rect:Rect2 = current_level_node.get_used_rect()
	tile_map_rect.position *= current_level_node.cell_size
	tile_map_rect.size *= current_level_node.cell_size
	var screen_size = get_viewport_rect().size
	screen_size -= Vector2(200,600)
	current_level_node.position += - tile_map_rect.position - tile_map_rect.size/2
	var scale_diff = screen_size/tile_map_rect.size
	scale = 1.2 * Vector2.ONE * min(scale_diff.x,scale_diff.y)
	current_level_node.fill_walls()

func check_for_popup():
	if current_level_node.hint_text == "":
		return
	get_node("../LevelUI/Hint/Label").text = current_level_node.hint_text
	get_node("../LevelUI/Hint").popup_centered()

func level_pressed(levelName):
	LevelData.set_current_level(levelName)
	get_node("../LevelUI/LevelSelector").visible = false
	startLevel()

func _on_btnReset_pressed():
	startLevel(false)

func _on_btnMenu_pressed():
	Transition.goto_levels_scene()

func _on_btnNext_pressed():
	LevelData.set_level_next()
	startLevel()

func _on_btnBack_pressed():
	LevelData.set_level_prev()
	startLevel()


func _on_btnLevels_pressed():
	get_node("../LevelUI/LevelSelector").popup_centered()
