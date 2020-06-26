extends PlayerState

var original_gravity: = 0.0
var gravity_scale: = 0.4
var jump_scale: = 0.5
var jump_impulse: = 10.0

func unhandled_input(event: InputEvent) -> void:
	if !(event is InputEventMouseMotion) && Event.mouse_captured:
		player.unhandled_input(event)

func get_input_direction()->void:
	var basis:Basis = player.body.global_transform.basis
	var direction = Vector3.ZERO
	direction -= Input.get_action_strength("move_up") * basis.z
	player.direction = direction.normalized() * player.move_speed

func air_gravity_logic(delta:float)->void:
	if player.is_jumping:
		if !player.jump:										#released jump button mid-air
			player.is_jumping = false
	else:
		if player.jump:											#trigger jump away from wall
			player.velocity.y = player.jump_speed * jump_scale
			player.velocity += jump_impulse * player.body.global_transform.basis.z
			player.is_jumping = true
	player.velocity.y -= player.gravity * delta					#apply gravity even when grounded to make stopping on slopes work

func physics_process(delta: float) -> void:
	get_input_direction()
	player.velocity_logic(delta)
	air_gravity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()


func process(delta: float) -> void:
	state_check()


func state_check()->void:
	if player.is_grounded:
		if player.direction.length() > 0.1:
			_state_machine.transition_to("Run")
		else:
			_state_machine.transition_to("Idle")
	else:
		if player.velocity.y <= 0.0 || !Input.is_action_pressed("move_up"):
			_state_machine.transition_to("Jump")
		elif Input.is_action_just_pressed("jump"):									#jump away from wall
			_state_machine.transition_to("Jump", {acceleration = 0.2, time = 0.2})


func enter(msg := {}) -> void:
	var normal = msg.normal
	var forward = msg.forward
	#print(forward.dot(normal))
	var wall: = Vector2(normal.x, normal.z).normalized()
	var front: = Vector2(forward.x, forward.z).normalized()
	player.body.rotate_y(wall.angle_to(front))
	original_gravity = player.gravity
	player.gravity = original_gravity * gravity_scale


func exit() -> void:
	player.gravity = original_gravity
