extends TileMap

export var randomiseBackground:bool = true
var rng = RandomNumberGenerator.new()
var void_tile_random_id = 12
var void_dots_tile_id_offset = -6

var LevelNode = get_parent()

func _ready():
	Globals.initialise_buttons()
	LevelData.initialiseMoveCount()
	randomiseBackgroundTiles()

func randomiseBackgroundTiles():
	if not randomiseBackground:
		return
	rng.randomize()
	var tile_id_to_randomize = void_tile_random_id
	var tile_array = get_used_cells_by_id(tile_id_to_randomize)
	for tile in tile_array:
		set_cellv(tile, void_tile_random_id + void_dots_tile_id_offset + rng.randi_range(0,5))
