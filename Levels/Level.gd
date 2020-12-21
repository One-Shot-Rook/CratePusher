extends TileMap

var LevelNode = get_parent()

func _ready():
	Globals.initialiseObjectPhases()
	Globals.initialiseButtonSignals()
	LevelData.initialiseMoveCount()
