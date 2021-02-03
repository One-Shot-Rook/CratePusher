extends Sprite

const DEV = 3

var rng = RandomNumberGenerator.new()
var dev = 1.0
var col = Color("fcffd6")

export var star_id:int
onready var center = position
onready var electric = get_node_or_null("Electric")

func _ready():
	rng.randomize()

func _physics_process(_delta):
	position = center + Vector2(rng.randfn(0,dev),rng.randfn(0,dev))

func update_ui(stars):
	if stars == 4:
		modulate = col
		dev = DEV + 1
		electric.width = 0.20
	elif stars >= star_id:
		modulate = Color.white
		dev = DEV
		electric.width = 0.20
	else:
		modulate = Color(0.3,0.3,0.3)
		dev = 0
		electric.width = 0.02
