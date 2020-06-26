extends PlayerState


func unhandled_input(event: InputEvent) -> void:
	parent.unhandled_input(event)


func physics_process(delta: float) -> void:
	parent.physics_process(delta)


func process(delta: float) -> void:
	state_check()


func state_check()->void:
	if player.is_grounded:
		if player.direction.length() > 0.1:
			_state_machine.transition_to("Run")
		else:
			_state_machine.transition_to("Idle")
	else:
		if !player.was_wallrunning && player.is_on_wall():
			var normal: Vector3 = player.get_slide_collision(0).normal
			var forward: Vector3 = player.body.global_transform.basis.z
			var dot: = forward.dot(normal)
			if player.velocity.y > 0.0:
				if dot > 0.97:
					_state_machine.transition_to("FrontWallRun", {normal = normal, forward = forward})
				elif dot > 0.0 and dot < 0.65:
					_state_machine.transition_to("SideWallRun", {normal = normal, forward = forward})


func enter(msg := {}) -> void:
	if msg.has('acceleration'):
		player.acceleration = msg.acceleration
		yield(get_tree().create_timer(msg.time),"timeout")
		player.acceleration = player.default_acceleration


func exit() -> void:
	player.acceleration = player.default_acceleration
