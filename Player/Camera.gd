extends Camera


export (float) var mouse_sensitivity = 0.3

onready var body = get_parent()


var camera_x_rotation: = 0.0

func mouse_look(event:InputEvent)->void:
	body.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
	var x_delta = event.relative.y * mouse_sensitivity
	if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90:
		rotate_x(deg2rad(-x_delta))
		camera_x_rotation += x_delta
