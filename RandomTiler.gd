extends TileMap

var tile_array = [9,14]

var rng = RandomNumberGenerator.new()
var offset = {"x":0,"y":0}

func _ready():
	rng.randomize()
	
	for x in range(-30,30):
		for y in range(-30,30):
			var index = int(random(x,y)) % tile_array.size()
			set_cell(x,y,tile_array[index])
	update_bitmask_region(-30 * Vector2.ONE, 30 * Vector2.ONE)

func random(x,y):
	var new_x = abs(offset.x + x)
	var new_y = abs(offset.y + y)
	return pow(pow(new_x,0.5)+pow(new_y,0.5),2)
