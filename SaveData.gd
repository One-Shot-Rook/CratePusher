extends Node

var maxWorlds = 2
var current_world:int = 1 setget set_current_world, get_current_world
var levelProgress = {}
var audioLevels = {"Master":0,"Voice":0,"Music":0,"SFX":0}

var saveVariables = [
	"levelProgress",
	"audioLevels",
	"currentWorld"
]

func set_current_world(value) -> bool:
	if value > maxWorlds or value < 1:
		return false
	current_world = value
	return true

func get_current_world() -> int:
	return current_world

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
	var dir_world = Directory.new()
	dir_world.open("res://Levels")
	dir_world.list_dir_begin(true,true)
	var path_string_world = dir_world.get_next()
	while path_string_world != "":
		if "World" in path_string_world:
			var dir_level = Directory.new()
			dir_level.open("res://Levels/" + path_string_world)
			dir_level.list_dir_begin(true,true)
			var path_string_level = dir_level.get_next()
			while path_string_level != "":
				if "level" in path_string_level:
					var levelID = path_string_level.split(".")[0]#.trim_prefix("level")
					var level_key = (str(path_string_world.trim_prefix("World")) + "-" + str(path_string_level.trim_prefix("level"))).trim_suffix(".tscn")
					print(level_key)
					levelProgress[level_key] = {"Stars":0, "Coins":[0]}
				path_string_level = dir_level.get_next()
		path_string_world = dir_world.get_next()

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
	get_tree().call_group("level_select","updateUI")
