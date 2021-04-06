extends Control

enum BUS_CHANNELS{MASTER,NARRATOR,MUSIC,SFX}
var initialChanges = true

func _ready():
	$gridOptions/sliderMaster.value = AudioServer.get_bus_volume_db(0)
	#$gridOptions/sliderVoice.value = AudioServer.get_bus_volume_db(1)
	$gridOptions/sliderMusic.value = AudioServer.get_bus_volume_db(2)
	$gridOptions/sliderSFX.value = AudioServer.get_bus_volume_db(3)
	initialChanges = false

func _on_sliderMaster_value_changed(value):
	AudioServer.set_bus_volume_db(BUS_CHANNELS.MASTER,value)
	if initialChanges:
		return
	settingChanged()

func _on_sliderVoice_value_changed(value):
	AudioServer.set_bus_volume_db(BUS_CHANNELS.NARRATOR,value)
	if initialChanges:
		return
	$sndVoice.play()
	settingChanged()

func _on_sliderMusic_value_changed(value):
	AudioServer.set_bus_volume_db(BUS_CHANNELS.MUSIC,value)
	if initialChanges:
		return
	settingChanged()

func _on_sliderSFX_value_changed(value):
	AudioServer.set_bus_volume_db(BUS_CHANNELS.SFX,value)
	if initialChanges:
		return
	$sndSFX.play()
	settingChanged()


func settingChanged():
	$btnBack.text = "Apply"

func _on_btnApply_pressed():
	SaveData.saveGame()

func _on_btnBack_pressed():
	if $btnBack.text == "Apply":
		SaveData.updateAudioLevels()
		SaveData.saveGame()
	$btnBack.text = "Back"
