extends Node

onready var sndMusic:AudioStreamPlayer = $sndMusic
onready var twnVolumeDB:Tween = $twnVolumeDB

var twnError

func _ready():
	startTrack(load("res://Assets/Sounds/mus_menu.wav"))

func changeTrack(stream:AudioStream):
	if sndMusic.stream == stream:
		return
	stopTrack()
	twnError = twnVolumeDB.connect("tween_all_completed",self,"startTrack",[stream],CONNECT_ONESHOT)

func stopTrack():
	twnError = twnVolumeDB.connect("tween_all_completed",sndMusic,"stop",[],CONNECT_ONESHOT)
	twnError = twnVolumeDB.interpolate_property(sndMusic,"volume_db",null,-80,1,Tween.TRANS_CUBIC,Tween.EASE_IN)
	twnError = twnVolumeDB.start()

func startTrack(stream:AudioStream):
	print("start ",stream)
	sndMusic.stop()
	sndMusic.stream = stream
	sndMusic.play()
	twnError = twnVolumeDB.interpolate_property(sndMusic,"volume_db",null,-15,0.5,Tween.TRANS_CUBIC,Tween.EASE_IN)
	twnError = twnVolumeDB.start()
