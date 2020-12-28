extends Control

onready var tween = get_node("Tween")

var rng = RandomNumberGenerator.new()

var p = pow(2,1.0/12)
var pitchDict = {
	"A" :pow(p,-3),
	"A#":pow(p,-2), "Bb":pow(p,-2),
	"B" :pow(p,-1),
	"C" :pow(p,0),
	"C#":pow(p,1), "Db":pow(p,1),
	"D" :pow(p,2),
	"D#":pow(p,3), "Eb":pow(p,3),
	"E" :pow(p,4),
	"F" :pow(p,5),
	"F#":pow(p,6), "Gb":pow(p,6),
	"G" :pow(p,7),
	"G#":pow(p,8), "Ab":pow(p,8),
	}
var pitchRanges = [
	pitchDict["C"],
	pitchDict["D"],
	pitchDict["E"],
	pitchDict["F"],
	pitchDict["G"],
	]

func _ready():
	rect_position = Vector2.ZERO

func buttonWasPressed():
	var sndButton = AudioStreamPlayer.new()
	sndButton.stream = load("res://Assets/Sounds/snd_boop.wav")
	rng.randomize()
	var pitch = pitchRanges[rng.randi_range(0,pitchRanges.size()-1)]
	sndButton.pitch_scale = pitch
	sndButton.volume_db = -25
	sndButton.connect("finished",sndButton,"queue_free")
	add_child(sndButton)
	sndButton.play()

func _on_btnPlay_pressed():
	buttonWasPressed()
	tween.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(0,1920), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_btnSettings_pressed():
	buttonWasPressed()
	tween.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(1080,0), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_btnCredits_pressed():
	buttonWasPressed()
	tween.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(-1080,0), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_btnShop_pressed():
	buttonWasPressed()
	tween.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(0,-1920), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_btnBack_pressed():
	buttonWasPressed()
	tween.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(0,0), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_btnReset_pressed():
	buttonWasPressed()
	SaveData.resetSaveData()
