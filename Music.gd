extends Node

onready var sndMusic:AudioStreamPlayer = $sndMusic
onready var twnVolumeDB:Tween = $twnVolumeDB

var twnError

var theme_Menu = load("res://Assets/Sounds/mus_menu.wav")
var theme_Ambience = load("res://Assets/Sounds/mus_ambience.wav")

#func changeTrack(stream:AudioStream):
#	if sndMusic.stream == stream:
#		return
#	var trackToStop = stopTrack()
#	if trackToStop:
#		twnError = twnVolumeDB.connect("tween_all_completed",self,"startTrack",[stream],CONNECT_ONESHOT)
#	else:
#		startTrack(stream)

func stopTrack():
	if not sndMusic.playing:
		return
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