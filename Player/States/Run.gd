extends PlayerState

func unhandled_input(event: InputEvent) -> void:
	parent.unhandled_input(event)


func physics_process(delta: float) -> void:
	parent.physics_process(delta)


func process(delta: float) -> void:
	state_check()


func state_check()->void:
	if player.is_grounded:
		if player.direction.length() < 0.1:
			_state_machine.transition_to("Idle")
	else:
		if !player.is_jumping:
			player.jump_buffer.start()
		_state_machine.transition_to("Jump")


func enter(msg := {}) -> void:
	pass


func exit() -> void:
	pass
