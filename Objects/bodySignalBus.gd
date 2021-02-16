class_name SignalBus
extends Node

signal OR_update(state)
signal AND_update(state)

var signal_id:int = 0

var received_signals:int = 0 setget set_received_signals
var input_signals:int = 0

func set_received_signals(new_value):
	received_signals += new_value
	check_signals()

func check_signals():
	#print(" signals: ",received_signals)
	if received_signals > 0:
		emit_signal("OR_update",true)
	else:
		emit_signal("OR_update",false)
	if received_signals == input_signals:
		emit_signal("AND_update",true)
	else:
		emit_signal("AND_update",false)
