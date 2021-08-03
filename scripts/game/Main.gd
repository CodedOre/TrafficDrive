# Copyright 2021, Frederick Schenk

# --- Main Script ---
# The script that is the game.

extends Node

# -- Enums --

# - The state of this scene -
enum GameState {SELECT, DRIVE}

# -- Variables --

# - The states and the corresponding nodes -
onready var game_states : Dictionary = {
	GameState.SELECT : $States/VehicleSelect,
	GameState.DRIVE  : $States/Driving
}

# - Internal nodes -
onready var state_manager : Node = $States

# -- Functions --

# - Runs at startup -
func _ready():
	# Sets the first state
	set_active_state(GameState.DRIVE)

# - Sets a state to be active -
func set_active_state(key) -> void:
	if ! game_states.has(key):
		push_error("Main: No correct state set!")
		return
	for state in game_states.keys():
		if state == key:
			_enable_state(game_states[state])
		else:
			_disable_state(game_states[state])

# - Enables a state to be run -
func _enable_state(state: GameState) -> void:
	state_manager.add_child(state)
	state._state_camera.make_current()

# - Disables a state to not run -
func _disable_state(state: GameState) -> void:
	state_manager.remove_child(state)
