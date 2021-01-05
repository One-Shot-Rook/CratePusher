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
	for texStar in $ctnStars.get_children():
		if int(texStar.name[-1]) > stars:
			texStar.modulate = Color(0,0,0,1)
