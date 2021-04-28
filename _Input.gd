extends Node

const theme = preload("res://Assets/Themes/theme_main.tres")
const CRATE_KEYS = {
	"WOOD":KEY_0,
	"RED":KEY_1,
	"BLUE":KEY_2,
	"PURP":KEY_3}

var enabled = false
var active_crate:Crate setget set_active_crate

var keys_pressed = []
var mouse_start:Vector2 = Vector2.ZERO
var mouse_end:Vector2 = Vector2.ZERO

var container:HBoxContainer

var line2D:Line2D
var sprite:Sprite

func set_active_crate(new_crate):
	if new_crate == active_crate:
		active_crate = null
	else:
		active_crate = new_crate


func _ready():
	add_input_line()
	add_input_circle()

func _unhandled_input(event):
	
	if not enabled or not active_crate:
		return
	
	if event is InputEventScreenTouch:
		
		if event.pressed:
			
			if event.position.y < 200:
				return
			
			if mouse_start == Vector2.ZERO:
				
				mouse_start = event.position
				mouse_end = event.position
			
			line2D.visible = true
			sprite.position = mouse_start
			sprite.visible = true
			
		else:
			var rel_vector = event.position - mouse_start
			if rel_vector.length() >= SaveData.input_radius:
				var angle = rel_vector.angle()
				angle = stepify(angle,PI/2)
				var input_vector = Vector2(cos(angle),sin(angle))
				active_crate.direction_pressed(input_vector)
			
			mouse_start = Vector2.ZERO
			mouse_end = Vector2.ZERO
			
			line2D.visible = false
			sprite.visible = false
		
		update_input_line()
	
	elif event is InputEventScreenDrag:
		
		mouse_end = event.position
		update_input_line()

func _unhandled_key_input(event) -> void:
	
	if not enabled:
		return
	
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
	crate_array = sort_crates(crate_array)
	for object in crate_array:
		if object:
			add_button(object)
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

func add_input_circle():
	sprite = Sprite.new()
	sprite.texture = load("res://Assets/Sprites/circle.svg")
	update_input_circle_scale()
	sprite.visible = false
	add_child(sprite)

func update_input_circle_scale():
	sprite.scale = Vector2.ONE * SaveData.input_radius/150.0

func add_input_line():
	line2D = Line2D.new()
	line2D.width = 4
	line2D.points = PoolVector2Array([Vector2.ZERO , Vector2.ZERO])
	add_child(line2D)

func update_input_line():
	line2D.points[0] = mouse_start
	line2D.points[1] = mouse_end
	if (mouse_start-mouse_end).length() >= SaveData.input_radius:
		line2D.default_color = Color.green
	else:
		line2D.default_color = Color.red

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
	var _error = button.connect("pressed",self,"set_active_crate",[crate])
	_error = crate.connect("active_state_changed",button,"set_disabled")
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(button)

func sort_crates(crate_array):
	
	var sorted_array = [null,null,null,null]
	for crate in crate_array:
		sorted_array[crate.crate_type] = crate
	sorted_array[0] = null # Overwrite wooden slot
	return sorted_array



