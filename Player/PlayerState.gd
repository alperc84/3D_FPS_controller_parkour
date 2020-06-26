class_name PlayerState
extends State
# Base type for the player's state classes. Contains boilerplate code to get
# autocompletion and type hints.

onready var player: = owner

var next_state: = {}	#Can be used in special case situations
