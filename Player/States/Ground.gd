extends PlayerState

func unhandled_input(event: InputEvent) -> void:
	player.unhandled_input(event)

func physics_process(delta:float)->void:	#StateMachine calls if this is current state
	player.ground_physics_process(delta)
