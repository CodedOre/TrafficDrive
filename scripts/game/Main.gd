# Copyright 2021, Frederick Schenk

# --- Main Script ---
# The script that is the game.

extends Node

# -- Enums --

# - The state of this scene -
enum GameState {TITLE, SELECT, DRIVE}

# -- Variables --

# - Internal nodes -
onready var city = $GameCity

# - The nodes for the various states -
onready var state_title_screen   = $States/TitleScreen
onready var state_vehicle_select = $States/VehicleSelect
onready var state_driving        = $States/Driving

# - The states and the corresponding nodes -
onready var game_states : Dictionary = {
	GameState.TITLE  : state_title_screen,
	GameState.SELECT : state_vehicle_select,
	GameState.DRIVE  : state_driving
}

# - Internal nodes -
onready var state_manager : Node = $States

# -- Functions --

# - Runs at startup -
func _ready():
	# Sets the first state
	set_active_state(GameState.TITLE)

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
func _enable_state(state: Spatial) -> void:
	if ! state.is_inside_tree():
		state_manager.add_child(state)
	state._state_camera.make_current()

# - Disables a state to not run -
func _disable_state(state: Spatial) -> void:
	if state.is_inside_tree():
		state_manager.remove_child(state)

# - State change from TitleScreen to VehicleSelect -
func select_a_vehicle() -> void:
	# Change states
	set_active_state(GameState.SELECT)

# - State change from VehicleSelect to Driving -
func drive_selected_vehicle() -> void:
	# Get selected vehicle
	var selected_vehicle : String    = state_vehicle_select.chosen_vehicle()
	var paint            : int       = state_vehicle_select.chosen_paint()
	var vehicle_spawn    : Transform = state_vehicle_select.vehicle_spawn()
	# Change states
	set_active_state(GameState.DRIVE)
	# Activates the city time
	city.set_pause(false)
	# Setup new scene
	state_driving.setup_driving(selected_vehicle, paint, vehicle_spawn)

# - State change to TitleScreen -
func return_to_main() -> void:
	# Resets the city time
	city.set_pause(true)
	# Sets pause mode (in case we're coming from Driving)
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Change states
	set_active_state(GameState.TITLE)

# - Stops the city time when paused -
func check_pause():
	city.set_pause(game_states[GameState.DRIVE].paused)
