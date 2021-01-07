extends Button

var stars:int = 0

func _ready():
	updateUI()

func updateUI():
	var tempName = text
	if int(text) < 10:
		tempName = "0" + text
	if not SaveData.levelProgress.has("level" + tempName):
		SaveData.resetSaveData()
	stars = SaveData.levelProgress["level" + tempName]["Stars"]
	$texChip.texture = load("res://Assets/UI/img_chip_" + str(stars) + ".png")
