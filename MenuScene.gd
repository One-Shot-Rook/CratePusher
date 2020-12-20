extends Control

onready var tween = get_node("Tween")

func _ready():
	rect_position = Vector2.ZERO

func _on_PlayBtn_pressed():
	tween.interpolate_property(self, "rect_position", rect_position, Vector2(0,1920), 1, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()


func _on_SettingsBtn_pressed():
	pass # Replace with function body.


func _on_CreditsBtn_pressed():
	pass # Replace with function body.


func _on_BackBtn_pressed():
	tween.interpolate_property(self, "rect_position", rect_position, Vector2(0,0), 1, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()
