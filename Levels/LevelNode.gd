extends Node2D

var current_level_node

func _ready():
	startLevel()

func startLevel(level_name=LevelData.current_level):
	if current_level_node:
		current_level_node.free()
	LevelData.set_current_level(level_name)
	#print(level_name.split("-")[1])
	var loadpath = "res://Levels/World" + str(SaveData.get_current_world()) + "/" + "level" + level_name.split("-")[1] + ".tscn"
	var levelXX:GameLevel = load(loadpath).instance()
	levelXX.level_name = level_name
	current_level_node = levelXX
	add_child(current_level_node)
	
	center_level()

func center_level():
	
	var tile_map_rect:Rect2 = current_level_node.get_tile_map_rect()
	var screen_size = get_viewport_rect().size
	current_level_node.position += - tile_map_rect.position - tile_map_rect.size/2
	var scale_diff = screen_size/tile_map_rect.size
	scale = Vector2.ONE * min(scale_diff.x,scale_diff.y)

func _on_btnReset_pressed():
	startLevel()

func _on_btnMenu_pressed():
	Transition.goto_levels_scene()

func _on_btnNext_pressed():
	LevelData.set_level_next()
	startLevel()

func _on_btnBack_pressed():
	LevelData.set_level_prev()
	startLevel()
