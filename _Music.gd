extends Node

onready var sndMusic:AudioStreamPlayer = $sndMusic
onready var twnVolumeDB:Tween = $twnVolumeDB

var twnError

var theme_Menu = load("res://Assets/Sounds/mus_background1.wav")
var theme_Ambience = load("res://Assets/Sounds/mus_background1.wav")
var theme_background1 = load("res://Assets/Sounds/mus_background1.wav")

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
	pitchDict["E"],
	pitchDict["E"],
	pitchDict["G"],
	pitchDict["B"],
	pitchDict["C"],
	]
var noteArray = pitchRanges.duplicate(true)


func stopTrack():
	if not sndMusic.playing:
		return
	twnError = twnVolumeDB.connect("tween_all_completed",sndMusic,"stop",[],CONNECT_ONESHOT)
	twnError = twnVolumeDB.interpolate_property(sndMusic,"volume_db",null,-80,1,Tween.TRANS_QUAD,Tween.EASE_IN)
	twnError = twnVolumeDB.start()

func startTrack(stream:AudioStream):
	sndMusic.stop()
	sndMusic.stream = stream
	sndMusic.play()
	twnError = twnVolumeDB.interpolate_property(sndMusic,"volume_db",null,-15,1,Tween.TRANS_QUAD,Tween.EASE_OUT)
	twnError = twnVolumeDB.start()

func button_was_pressed() -> void:
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








