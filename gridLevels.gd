extends GridContainer

var load_btnLevel = load("res://btnLevel.tscn")

func _ready():
	var dir = Directory.new()
	dir.open("res://Levels")
	dir.list_dir_begin(true,true)
	var pathString = dir.get_next()
	while pathString != "":
		if "level" in pathString:
			createLevelButton(pathString)
		pathString = dir.get_next()

func createLevelButton(pathString:String):
	var btnLevel = load_btnLevel.instance()
	#btnLevel.size_flags_horizontal = Button.SIZE_EXPAND_FILL
	var levelName = pathString.split(".")[0]
	btnLevel.text = levelName.trim_prefix("level")
	#btnLevel.enabled_focus_mode = Control.FOCUS_NONE
	btnLevel.connect("pressed",self,"levelPressed",[levelName])

	add_child(btnLevel)

func levelPressed(levelName:String):
	LevelData.setCurrentLevel(levelName)
	var _ERROR_CODE = get_tree().change_scene("res://Levels/Main.tscn")
