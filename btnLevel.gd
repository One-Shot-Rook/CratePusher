extends Button

var stars:int = 0

func _ready():
	updateUI()

func updateUI():
	if not SaveData.levelProgress.has("level" + text):
		SaveData.resetSaveData()
	stars = SaveData.levelProgress["level" + text]["Stars"]
	for texStar in $ctnStars.get_children():
		if int(texStar.name[-1]) > stars:
			texStar.modulate = Color(0,0,0,1)
