extends PlayerState

var original_gravity: = 0.0
var gravity_scale: = 0.4
var jump_scale: = 0.5
var jump_impulse: = 10.0
var direction:int
var run_normal:Vector2
var on_wall: = false

func unhandled_input(event: InputEvent) -> void:
	player.unhandled_input(event)

func get_input_direction()->void:
	var direction = Input.get_action_strength("move_up") * Vector3(run_normal.x, 0.0, run_normal.y)
	player.direction = direction.normalized() * player.move_speed

func air_gravity_logic(delta:float)->void:
	if player.is_jumping:
		if !player.jump:										#released jump button mid-air
			player.is_jumping = false
	else:
		if player.jump:											#trigger jump away from wall
			player.velocity = jump_impulse * -player.body.global_transform.basis.z
			player.velocity.y = player.jump_speed * jump_scale
			player.is_jumping = true
			on_wall = false
	player.velocity.y -= player.gravity * delta					#apply gravity even when grounded to make stopping on slopes work

static func get_wallrun_direction(normal:Vector2, _sign:int)->Vector2:
	return normal.rotated(PI * 0.51 * _sign).normalized()

func wall_update_logic()->void:
	if player.is_grounded:
		on_wall = false
		return
		
	if !on_wall || !player.is_on_wall():
		on_wall = false
		return
		
	var collision:KinematicCollision = player.get_slide_collision(0)	
	var normal:Vector3 = collision.normal
	var v2_normal: = Vector2(normal.x, normal.z)
	if abs(run_normal.dot(v2_normal)) < 0.3:
		run_normal = get_wallrun_direction(v2_normal, direction)

func physics_process(delta: float) -> void:
	get_input_direction()
	player.velocity_logic(delta)
	air_gravity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()
	wall_update_logic()


func process(delta: float) -> void:
	state_check()


func state_check()->void:
	if player.is_grounded:
		if player.direction.length() > 0.1:
			_state_machine.transition_to("Run")
		else:
			_state_machine.transition_to("Idle")
	else:
		if !on_wall || Input.is_action_just_pressed("jump") || !Input.is_action_pressed("move_up"):
			_state_machine.transition_to("Jump")


func enter(msg := {}) -> void:
	var normal = msg.normal
	var forward = msg.forward
	var wall: = Vector2(normal.x, normal.z).normalized()
	var front: = Vector2(forward.x, forward.z).normalized()
	var angle: = front.angle_to(wall)
	direction = sign(angle)
	run_normal = get_wallrun_direction(wall, direction)
	on_wall = true
	original_gravity = player.gravity
	player.gravity = original_gravity * gravity_scale
	player.was_wallrunning = true							#disable chaining wallruns


func exit() -> void:
	player.gravity = original_gravity
