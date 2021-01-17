extends GridContainer

var load_btnLevel = load("res://btnLevel.tscn")

func _ready():
	var path = "res://Levels/World" + name.trim_prefix("gridLevel")
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
	btnLevel.text = name.trim_prefix("gridLevel") + "-" + levelName.trim_prefix("level")
	btnLevel.connect("pressed",get_parent().get_parent(),"levelPressed",[name.trim_prefix("gridLevel") + "-" + levelName.trim_prefix("level")])
	add_child(btnLevel)
