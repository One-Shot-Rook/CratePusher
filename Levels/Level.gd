extends TileMap

export var randomiseBackground:bool = false
var rng = RandomNumberGenerator.new()
var void_tile_id = 3
var void_dots_tile_id_offset = 3

var LevelNode = get_parent()

func _ready():
	Globals.initialiseObjectPhases()
	Globals.initialiseButtonSignals()
	LevelData.initialiseMoveCount()
	randomiseBackgroundTiles()

func randomiseBackgroundTiles():
	if not randomiseBackground:
		return
	rng.randomize()
	var tile_id_to_randomize = void_tile_id
	var tile_array = get_used_cells_by_id(tile_id_to_randomize)
	for tile in tile_array:
		if rng.randi_range(0,4) > 0:
			set_cellv(tile, void_tile_id + void_dots_tile_id_offset + rng.randi_range(0,5))
