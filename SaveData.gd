extends Node

var levelProgress = {
	
}

var saveVariables = [
	"levelProgress"
]

func updateLevelStars(levelID, stars):
	if levelProgress[levelID]["Stars"] > stars:
		return
	levelProgress[levelID]["Stars"] = stars
	saveGame()

func _ready():
	initialiseData()
	loadGame()

func initialiseData():
	var dir = Directory.new()
	dir.open("res://Levels")
	dir.list_dir_begin(true,true)
	var pathString = dir.get_next()
	while pathString != "":
		if "level" in pathString:
			var levelID = pathString.split(".")[0]#.trim_prefix("level")
			levelProgress[levelID] = {"Stars":0, "Coins":[0]}
		pathString = dir.get_next()

func resetSaveData():
	initialiseData()
	saveGame()

func createSaveData(): # Copy the state of the game to a save dict
	var saveData = {}
	for variable in saveVariables:
		saveData[variable] = get(variable)
	return saveData

func loadSaveData(saveData): # Set the state of the game from a save dict
	for variable in saveData:
		set(variable,saveData[variable])

func saveGame(): # Create save file
	var saveFile = File.new()
	var saveData = createSaveData()
	saveFile.open("user://saveFile.json", File.WRITE)
	saveFile.store_line(to_json(saveData))
	saveFile.close()

func loadGame(): # Load save file
	var saveFile = File.new()
	if not saveFile.file_exists("user://saveFile.json"):
		return
	saveFile.open("user://saveFile.json", File.READ)
	var saveData = parse_json(saveFile.get_line())
	saveFile.close()
	loadSaveData(saveData)
