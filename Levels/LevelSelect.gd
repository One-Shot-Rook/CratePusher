extends GridContainer

onready var LevelNode = get_tree().get_root().get_node("Main/LevelNode")

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
	var btnLevel = Button.new()
	btnLevel.size_flags_horizontal = Button.SIZE_EXPAND_FILL
	var levelName = pathString.split(".")[0]
	btnLevel.text = levelName
	btnLevel.connect("button_down",LevelNode,"startLevel",[levelName])
	btnLevel.connect("button_down",Music,"changeTrack",[load("res://Assets/Sounds/mus_ambience.wav")])
	add_child(btnLevel)
