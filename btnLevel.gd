extends Button

var stars:int = 0

func _ready():
	stars = SaveData.levelProgress["level" + text]["Stars"]
	for texStar in $ctnStars.get_children():
		if int(texStar.name[-1]) > stars:
			texStar.modulate = Color(0,0,0,1)


