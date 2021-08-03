# Copyright 2021, Frederick Schenk

# --- Main Script ---
# The script that is the game.

extends Node

# -- Enums --

# - The state of this scene -
enum GameState {SELECT, DRIVE}

# -- Variables --

# - The nodes for the various states -
onready var state_vehicle_select = $States/VehicleSelect
onready var state_driving        = $States/Driving

# - The states and the corresponding nodes -
onready var game_states : Dictionary = {
	GameState.SELECT : state_vehicle_select,
	GameState.DRIVE  : state_driving
}

# - Internal nodes -
onready var state_manager : Node = $States

# -- Functions --

# - Runs at startup -
func _ready():
	# Setup VehicleSelect
	state_vehicle_select.connect("menu_confirm", self, "drive_selected_vehicle")
	# Sets the first state
	set_active_state(GameState.SELECT)

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

# - State change from VehicleSelect to Driving -
func drive_selected_vehicle() -> void:
	# Get selected vehicle
	var selected_vehicle : String = state_vehicle_select.chosen_vehicle()
	# Change states
	set_active_state(GameState.DRIVE)
	# Setup new scene
	state_driving.setup_driving(selected_vehicle)
