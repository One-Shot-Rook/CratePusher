extends Node

signal direction_inputted(direction)

const drag_distance := 300
const theme = preload("res://Assets/Themes/theme_main.tres")
const CRATE_KEYS = {
	"WOOD":KEY_0,
	"RED":KEY_1,
	"BLUE":KEY_2,
	"PURP":KEY_3}

var keys_pressed = []
var mouse_start:Vector2 = Vector2.ZERO
var container:HBoxContainer
var enabled = false
var active_crate:Crate setget set_active_crate

func set_active_crate(new_crate):
	if new_crate == active_crate:
		active_crate = null
	else:
		active_crate = new_crate

func _unhandled_input(event):
	
	if not enabled or not active_crate:
		return
	
	if event is InputEventScreenTouch:
		
		if event.pressed:
			
			if mouse_start == Vector2.ZERO:
				
				mouse_start = event.position
			
		else:
			var rel_vector = event.position - mouse_start
			if rel_vector.length() >= drag_distance:
				var angle = rel_vector.angle()
				angle = stepify(angle,PI/2)
				var input_vector = Vector2(cos(angle),sin(angle))
				mouse_start = Vector2.ZERO
				active_crate.direction_pressed(input_vector)

func _unhandled_key_input(event) -> void:
	
	# Erase released key
	if not event.pressed and event.scancode in keys_pressed:
		keys_pressed.erase(event.scancode)
	
	# If key is already pressed
	if event.scancode in keys_pressed:
		return
	
	# Append new pressed key
	if event.pressed:
		keys_pressed.append(event.scancode)
	
	# Interpret direction input
	for button in container.get_children():
		if CRATE_KEYS[button.text] in keys_pressed:
			button.emit_signal("pressed")
			button.pressed = not button.pressed
	
	if not active_crate:
		return
	
	if KEY_UP in keys_pressed:
		active_crate.direction_pressed(Vector2.UP)
	elif KEY_RIGHT in keys_pressed:
		active_crate.direction_pressed(Vector2.RIGHT)
	elif KEY_DOWN in keys_pressed:
		active_crate.direction_pressed(Vector2.DOWN)
	elif KEY_LEFT in keys_pressed:
		active_crate.direction_pressed(Vector2.LEFT)


func enable_input_ui(crate_array):
	enabled = true
	add_container()
	for object in crate_array:
		var crate:Crate = object
		if crate.crate_type == Crate.CrateType.WOODEN:
			continue
		add_button(crate)
	var button_array = container.get_children()
	for button in button_array:
		for other_button in button_array:
			if button == other_button:
				continue
			button.connect("pressed",other_button,"set_pressed",[false])
	button_array[0].emit_signal("pressed")
	button_array[0].pressed = true

func disable_input_ui():
	enabled = false
	container.queue_free()

func add_container():
	container = HBoxContainer.new()
	container.mouse_filter = Control.MOUSE_FILTER_STOP
	container.theme = theme
	
	container.anchor_top = 0.9
	container.anchor_bottom = 1.0
	container.anchor_right = 1.0
	
	container.margin_bottom = -50
	container.margin_right = -50
	container.margin_left = 50
	add_child(container)

func add_button(crate:Crate):
	var button = Button.new()
	button.toggle_mode = true
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	match crate.crate_type:
		Crate.CrateType.RED:
			button.text = "RED"
		Crate.CrateType.BLUE:
			button.text = "BLUE"
		Crate.CrateType.PURPLE:
			button.text = "PURP"
	button.modulate = Globals.get_crate_color(crate.crate_type)
	button.connect("pressed",self,"set_active_crate",[crate])
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(button)


