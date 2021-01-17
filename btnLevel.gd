extends Button

var stars:int = 0

var level_name:String
var display_name:String

func _ready():
	level_name = text
	updateUI()

func updateUI():
	display_name = level_name.split("-")[1].trim_prefix("0")
	text = display_name
#	if int(text) < 10:
#		level_name = "0" + text
	if not SaveData.levelProgress.has(level_name):
		SaveData.resetSaveData()
	stars = SaveData.levelProgress[level_name]["Stars"]
	$texChip.texture = load("res://Assets/UI/img_chip_" + str(stars) + ".png")
