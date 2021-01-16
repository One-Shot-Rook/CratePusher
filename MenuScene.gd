extends Control

onready var twnPanel = get_node("twnPanel")

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
	pitchDict["E"],
	pitchDict["G"],
	]

var noteArray = pitchRanges.duplicate(true)

func _ready():
	Music.startTrack(Music.theme_Menu)
	rect_position = Vector2.ZERO

func buttonWasPressed() -> void:
	var sndButton = AudioStreamPlayer.new()
	sndButton.stream = load("res://Assets/Sounds/snd_boop.wav")
	if noteArray.empty():
		noteArray = pitchRanges.duplicate(true)
	rng.randomize()
	var noteIndex = rng.randi_range(0,noteArray.size()-1)
	var pitch = noteArray[noteIndex]
	noteArray.remove(noteIndex)
	sndButton.pitch_scale = pitch
	sndButton.volume_db = -25
	sndButton.bus = "Music"
	sndButton.connect("finished",sndButton,"queue_free")
	add_child(sndButton)
	sndButton.play()

func _on_btnPlay_pressed():
	buttonWasPressed()
	twnPanel.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(0,1920), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	twnPanel.start()

func _on_btnSettings_pressed():
	buttonWasPressed()
	twnPanel.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(1080,0), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	twnPanel.start()

func _on_btnCredits_pressed():
	buttonWasPressed()
	twnPanel.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(-1080,0), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	twnPanel.start()

func _on_btnShop_pressed():
	buttonWasPressed()
	twnPanel.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(0,-1920), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	twnPanel.start()

func _on_btnBack_pressed():
	buttonWasPressed()
	twnPanel.interpolate_property(
		self, 
		"rect_position", 
		rect_position, 
		Vector2(0,0), 
		0.5, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	twnPanel.start()

func _on_btnReset_pressed():
	SaveData.resetSaveData()
	get_tree().call_group("level_select","updateUI")

func _on_btnNote_pressed():
	buttonWasPressed()
	rng.randomize()
	var randColor = Color(rng.randf_range(0,1),rng.randf_range(0,1),rng.randf_range(0,1))
	$panelMenu/gridButtons/MarginContainer3/btnNote.modulate = randColor
