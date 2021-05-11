# A brief description of the class's role and functionality.
#
# A longer description if needed, possibly of multiple paragraphs. Properties and method names
# should be in backticks like so: `_process`, `x` etc.
#
# You can use *markdown* in the docstrings.
#
# Keep lines under 100 characters long.

#class_name
#tool
extends Node

var load_btnLevel = load("res://btnLevel.tscn")

func _ready():
	var path = "res://Levels/World" + str(SaveData.get_current_world())
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true,true)
	var pathString = dir.get_next()
	while pathString != "":
		if "level" in pathString:
			createLevelButton(pathString)
		pathString = dir.get_next()

func createLevelButton(pathString:String):
	var btnLevel = load_btnLevel.instance()
	var levelName = pathString.split(".")[0]
	btnLevel.text = str(SaveData.get_current_world()) + "-" + levelName.trim_prefix("level")
	btnLevel.connect("pressed",get_parent().get_parent().get_node("LevelNode"),"level_pressed",[str(SaveData.get_current_world()) + "-" + levelName.trim_prefix("level")])
	$grid.add_child(btnLevel)
	if LevelData.current_level == levelName:
		btnLevel.modulate
