#tool
extends TileMap

export var tile_set_floor_color:Color setget set_tile_set_floor_color

var LevelNode = get_parent()

func set_tile_set_floor_color(new_color):
	tile_set_floor_color = new_color
	tile_set.tile_set_modulate(tile_set.get_tiles_ids()[2],tile_set_floor_color)

func _ready():
	Globals.initialise_buttons()
	LevelData.initialiseMoveCount()
	Globals.react_to_crate_positions()
	#print(get_tile_map_rect())
	tile_set.tile_set_modulate(tile_set.get_tiles_ids()[1],Color(1,1,1,0))

func get_tile_map_rect() -> Rect2:
	var tile_vector_array = get_used_cells()
	var x = {"left":tile_vector_array[0].x,	"right":tile_vector_array[0].x}
	var y = {"top":tile_vector_array[0].y,	"bottom":tile_vector_array[0].y}
	for tile_vector in get_used_cells():
		# x checks
		if tile_vector.x < x.left:
			x.left = tile_vector.x
		elif tile_vector.x > x.right:
			x.right = tile_vector.x
		# y checks
		if tile_vector.y < y.top:
			y.top = tile_vector.y
		elif tile_vector.y > y.bottom:
			y.bottom = tile_vector.y
	
	# Convert to Rect2
	var start_vector = Vector2(x.left,y.top) * cell_size
	var end_vector = Vector2(x.right+1,y.bottom+1) * cell_size
	var size = end_vector - start_vector
	
	return Rect2(start_vector,size)


