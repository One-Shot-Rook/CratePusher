extends Control

export(Array,Color) var world_colors
export(NodePath) var path_particles

onready var partRain:CPUParticles2D = get_node(path_particles)
onready var twnPanel = get_node("twnPanel")

var rng = RandomNumberGenerator.new()

var MENU_POSITIONS = {
	"up":Vector2(0,1920),
	"right":Vector2(-1080,0),
	"down":Vector2(0,-1920),
	"left":Vector2(1080,0),
	"center":Vector2(0,0),
	}

func _ready():
	partRain.emitting = true
	Music.startTrack(Music.theme_Menu)
	rect_position = Vector2.ZERO
	update_world_ui()
	react_to_transition_meta_data()

func react_to_transition_meta_data():
	match Transition.meta_data:
		Transition.MetaData.DEFAULT:
			continue
		Transition.MetaData.MENU_NEW_WORLD:
			move_screen(MENU_POSITIONS.up)
			$panelLevels.move_to_world(+1)
		Transition.MetaData.MENU_LEVELS:
			rect_position = MENU_POSITIONS.up

func update_world_ui():
	var world_color = world_colors[SaveData.get_current_world()-1]
	material.set("shader_param/shadow_color",world_color)

func _on_btnPlay_pressed():
	Music.button_was_pressed()
	move_screen(MENU_POSITIONS.up)

func _on_btnSettings_pressed():
	Music.button_was_pressed()
	move_screen(MENU_POSITIONS.left)

func _on_btnCredits_pressed():
	Music.button_was_pressed()
	move_screen(MENU_POSITIONS.right)

func _on_btnShop_pressed():
	Music.button_was_pressed()
	move_screen(MENU_POSITIONS.down)
	#Transition.goto_level_editor_scene()

func _on_btnBack_pressed():
	Music.button_was_pressed()
	move_screen(MENU_POSITIONS.center)

func move_screen(to_position:Vector2):
	twnPanel.interpolate_property(
			self, "rect_position", 
			null, to_position, 
			0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	twnPanel.start()

func _on_btnReset_pressed():
	SaveData.resetSaveData()
	get_tree().call_group("level_select","updateUI")

func _on_btnNote_pressed():
	Music.button_was_pressed()
	rng.randomize()
	var randColor = Color(rng.randf_range(0,1),rng.randf_range(0,1),rng.randf_range(0,1))
	$panelMenu/gridButtons/MarginContainer3/btnNote.modulate = randColor


func _on_btnDonate_pressed():
	var _error = OS.shell_open("https://paypal.me/oneshotrook")
