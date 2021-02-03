tool
extends Node

var BUTTON_COLORS = [Color.red,Color.blue,Color.green,Color.yellow,Color.purple,Color.darkgoldenrod]
var CRATE_COLORS = [Color.burlywood,Color.lightcoral,Color.dodgerblue,Color.mediumslateblue]

func get_button_color(signal_id) -> Color:
	return BUTTON_COLORS[signal_id%BUTTON_COLORS.size()]

func get_crate_color(crate_id) -> Color:
	return CRATE_COLORS[crate_id]
