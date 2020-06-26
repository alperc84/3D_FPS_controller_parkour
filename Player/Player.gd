class_name Player
extends KinematicBody

export (float) 		var run_speed:				= 6.0
export (float) 		var walk_speed:				= 8.0	#4.0
export (float) 		var crouch_speed: 			= 2.0
export (float) 		var default_acceleration:	= 35.0
export (float) 		var default_gravity: 		= 20.0
export (float) 		var wallGravity: 			= 0.4
export (float) 		var jump_speed:				= 8.0
export (float) 		var walljump_speed:			= 9.0
export (float,1)	var air_control: 			= 0.6
export (float) 		var climb_power: 			= 15.0

#--------ABILITIES---------
export (float) 		var can_wallrun: 			= true
export (float) 		var can_walljump: 			= true

onready var state_machine:  = $StateMachine
onready var body:  			= $Body					#container used for rotating mesh, camera and raycasts
onready var camera:  		= $Body/Camera
onready var standShape: 	= $StandShape			#ColissionShape for standing
onready var crouchShape: 	= $CrouchShape			#ColissionShape for crouching
onready var standCheck: 	= $StandCheck			#Area box at head height - used for solid check when crouching
onready var rightRay: 		= $Body/RightRay		#from hip to side for wallrun detection
onready var leftRay: 		= $Body/LeftRay			#from hip to side for wallrun detection
onready var frontRay: 		= $Body/FrontRay		#points downwards to check for ledge jump
onready var wallRay: 		= $Body/WallRay			#points forwards to detect running up the wall (Genji / Hanzo in Overwatch)
onready var tween: 			= $Tween
onready var jump_buffer:	= $Jump_buffer			#Timer for allowing jump after loosing ground


const SNAP: 			= Vector3.DOWN * 0.2

var mouse_captured: 	= false

var move_speed:	 		= walk_speed
var acceleration:		= default_acceleration
var jump_release:		= jump_speed * 0.4
var gravity: 			= default_gravity
var direction: 			= Vector3.ZERO
var velocity: 			= Vector3.ZERO
var snap: 				= Vector3.ZERO

#-------STATES-----------
var is_wallrunning:		= false
var is_running: 		= false
var is_crouching: 		= false
var is_grounded: 		= false
var prev_grounded: 		= false
var is_jumping: 		= false
var was_wallrunning:	= false
var on_moving_platform: = false

var jump: = false #button

func unhandled_input(event:InputEvent)->void:
	if event is InputEventMouseMotion && Event.mouse_captured:
		camera.mouse_look(event)
	elif event.is_action_pressed("jump"):
		jump = true
	elif event.is_action_released("jump"):
		jump = false
	elif event.is_action_pressed("ui_cancel"):
		Event.mouse_captured = !Event.mouse_captured
	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _ready()->void:
	Event.mouse_captured = true


#----------Input and physics logics ---------------------
func get_input_direction() -> void:
	var basis:Basis = body.global_transform.basis
	direction = Vector3.ZERO
	direction += (Input.get_action_strength("move_down") - Input.get_action_strength("move_up")) * basis.z
	direction += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * basis.x
	direction = direction.normalized() * move_speed

func velocity_logic(delta:float)->void:
	velocity = velocity.move_toward(Vector3(direction.x, velocity.y, direction.z), acceleration * delta)

func gravity_logic(delta:float)->void:
	if is_grounded:
		if is_jumping:								#landed the jump
			jump = false							#force release jump button
			is_jumping = false
			snap = SNAP
		elif !is_jumping && jump:					#works also when re-pressed before ground for jump buffer (pre-landing)
			velocity.y = jump_speed
			is_jumping = true
			is_grounded = false
			snap = Vector3.ZERO
	else:
		if is_jumping:
			if !jump:								#released jump button mid-air
				is_jumping = false
				if velocity.y > jump_release:
					velocity.y = jump_release
#			else:
#				velocity.y -= gravity * delta
#		else:
#			velocity.y -= gravity * delta
	velocity.y -= gravity * delta					#apply gravity even when grounded to make stopping on slopes work
	velocity.y = min(velocity.y, jump_speed)

func ground_gravity_logic(delta:float)->void:
	if is_jumping:								#landed the jump
		jump = false							#force release jump button
		is_jumping = false
		snap = SNAP
	elif !is_jumping && jump:					#works also when re-pressed before ground for jump buffer (pre-landing)
		velocity.y = jump_speed
		is_jumping = true
		is_grounded = false
		snap = Vector3.ZERO
	velocity.y -= gravity * delta
	velocity.y = min(velocity.y, jump_speed)

func air_gravity_logic(delta:float)->void:
	if is_jumping:
		if !jump:								#released jump button mid-air
			is_jumping = false
			if velocity.y > jump_release:
				velocity.y = jump_release
	else:
		if jump:
			if !jump_buffer.is_stopped():
				jump_buffer.stop()
				velocity.y = jump_speed
				is_jumping = true
	velocity.y -= gravity * delta					#apply gravity even when grounded to make stopping on slopes work
	velocity.y = min(velocity.y, jump_speed)

func collision_logic()->void:
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true)
	#velocity = move_and_slide(velocity, Vector3.UP, true)

func ground_update_logic()->void:
	var temp_grounded: = is_on_floor()
	if is_grounded && !temp_grounded:					#just lost ground
		snap = Vector3.ZERO
	elif !is_grounded && temp_grounded:					#just landed
		snap = SNAP
		was_wallrunning = false
	
	is_grounded = temp_grounded

#---------Physics implementation ------------
func physics_process(delta:float)->void:		#Called from current PlayerState or overriden by State's own logic
	get_input_direction()
	velocity_logic(delta)
	gravity_logic(delta)
	collision_logic()
	ground_update_logic()

func ground_physics_process(delta:float)->void:		#Called from current PlayerState or overriden by State's own logic
	get_input_direction()
	velocity_logic(delta)
	ground_gravity_logic(delta)
	collision_logic()
	ground_update_logic()

func air_physics_process(delta:float)->void:		#Called from current PlayerState or overriden by State's own logic
	get_input_direction()
	velocity_logic(delta)
	air_gravity_logic(delta)
	collision_logic()
	ground_update_logic()







