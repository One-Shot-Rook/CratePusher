extends Button

var stars:int = 0

func _ready():
	updateUI()

func updateUI():
	var temp_name = text
#	if int(text) < 10:
#		temp_name = "0" + text
	if not SaveData.levelProgress.has(temp_name):
		SaveData.resetSaveData()
	stars = SaveData.levelProgress[temp_name]["Stars"]
	$texChip.texture = load("res://Assets/UI/img_chip_" + str(stars) + ".png")
