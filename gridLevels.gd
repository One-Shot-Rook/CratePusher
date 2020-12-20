extends GridContainer

var mainScene = preload("res://Levels/Main.tscn").instance()

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
	btnLevel.text = pathString.split(".")[0]
	btnLevel.connect("pressed",self,"levelPressed",[pathString])
	add_child(btnLevel)

func levelPressed(pathString:String):
	get_tree().get_root().add_child(mainScene)
	get_tree().change_scene("res://Levels/Main.tscn")
	var Level = get_tree().get_root().get_node("Main/Level")
	Level.startLevel(pathString)
