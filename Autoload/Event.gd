extends Node

signal MouseCapture(state)

var mouse_captured: = false setget on_mouse_captured

func on_mouse_captured(value: bool)->void:
	mouse_captured = value
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	emit_signal("MouseCapture", mouse_captured)

func _ready()->void:
	OS.center_window()	#just in case game window is not in the center (on my 4K its partialy out of the screen)
