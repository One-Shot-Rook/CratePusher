extends HBoxContainer

onready var Level = get_tree().get_root().get_node("Main/Level")

func _ready():
	var dir = Directory.new()
	dir.open("res://Levels")
	dir.list_dir_begin(true,true)
	var pathString = dir.get_next()
	while pathString != "":
		createLevelButton(pathString)
		pathString = dir.get_next()

func createLevelButton(pathString:String):
	var btnLevel = Button.new()
	btnLevel.size_flags_horizontal = Button.SIZE_EXPAND_FILL
	btnLevel.text = pathString.split(".")[0]
	btnLevel.connect("button_down",Level,"startLevel",[pathString])
	add_child(btnLevel)
