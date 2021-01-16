extends Node

var maxWorlds = 2
var current_world:int = 1 setget set_current_world, get_current_world
var levelProgress = {}
var audioLevels = {"Master":0,"Voice":0,"Music":0,"SFX":0}

var saveVariables = [
	"levelProgress",
	"audioLevels",
	"current_world"
]

func set_current_world(value) -> bool:
	if value > maxWorlds or value < 1:
		return false
	current_world = value
	return true

func get_current_world() -> int: return current_world

func updateAudioLevels():
	audioLevels["Master"] = AudioServer.get_bus_volume_db(0)
	audioLevels["Voice"]  = AudioServer.get_bus_volume_db(1)
	audioLevels["Music"]  = AudioServer.get_bus_volume_db(2)
	audioLevels["SFX"]    = AudioServer.get_bus_volume_db(3)

func updateLevelStars(levelID, stars):
	if levelProgress[levelID]["Stars"] > stars:
		return
	levelProgress[levelID]["Stars"] = stars
	saveGame()

func applyLoadedVariables():
	AudioServer.set_bus_volume_db(0,audioLevels["Master"])
	AudioServer.set_bus_volume_db(1,audioLevels["Voice"])
	AudioServer.set_bus_volume_db(2,audioLevels["Music"])
	AudioServer.set_bus_volume_db(3,audioLevels["SFX"])

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
	applyLoadedVariables()

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
