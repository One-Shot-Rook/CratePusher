extends Button

var stars:int = 0

var col = Color("fcffd6")

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
	#$texChip.texture = load("res://Assets/UI/img_chip_" + str(stars) + ".png")
	
	if stars == 4:
		$star1.modulate = col
		$star2.modulate = col
		$star3.modulate = col
	elif stars == 0:
		$star1.modulate = Color(0.3,0.3,0.3)
		$star2.modulate = Color(0.3,0.3,0.3)
		$star3.modulate = Color(0.3,0.3,0.3)
	else:
		for each in get_children():
			#print(each.name)
			if int(each.name.trim_prefix("star")) > stars:
				each.modulate = Color(0.3,0.3,0.3)
			else:
				each.modulate = Color.white
