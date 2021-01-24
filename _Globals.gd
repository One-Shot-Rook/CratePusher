tool
extends Node

var button_colors = [Color.red,Color.blue,Color.green,Color.yellow,Color.purple,Color.darkgoldenrod]
var crate_colors = [Color.burlywood,Color.lightcoral,Color.dodgerblue,Color.mediumslateblue]

func get_button_color(signal_id) -> Color:
	return button_colors[signal_id%button_colors.size()]

func get_crate_color(crate_id) -> Color:
	return crate_colors[crate_id]


