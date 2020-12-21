extends Control

onready var tween = get_node("Tween")

func _ready():
	rect_position = Vector2.ZERO

func _on_btnPlay_pressed():
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
	pass # Replace with function body.

func _on_btnCredits_pressed():
	pass # Replace with function body.

func _on_btnBack_pressed():
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
