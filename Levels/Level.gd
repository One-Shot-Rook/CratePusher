extends TileMap

var LevelNode = get_parent()

func _ready():
	Globals.initialiseButtonSignals()
	LevelData.initialiseMoveCount()
