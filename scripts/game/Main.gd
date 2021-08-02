# Copyright 2021, Frederick Schenk

# --- VehicleSelect Script ---
# The script for selecting a vehicle.

extends Spatial

# -- Enums --

# - The state of this scene -
enum GameState {NONE, TITLE, MENU, SELECT, DRIVE}

# -- Constants --

# - Speed the camera resets -
const MOVE_SPEED     : float = 1.0
const MOVE_THRESHOLD : float = 0.02

# -- Variables --

# - Internal nodes -
onready var camera : Camera  = $MainCamera

# - Scene views -
onready var title_view : Position3D = $Views/TitleView

# - Menus -
onready var vehicle_select : Spatial = $Menus/VehicleSelect

# - States of this scene -
var current_state = GameState.TITLE # GameState
var target_state  = GameState.TITLE # GameState

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	camera.global_transform = title_view.global_transform
	select_vehicle()

# - Runs every frame for transitions -
func _process(delta: float) -> void:
	# Transitions
	if current_state != target_state:
		_transition_view(delta)
		return
	# Running State
	match current_state:
		GameState.SELECT:
			_follow_camera_target()

# - Transitions to new view -
func _transition_view(delta: float) -> void:
	var camera_transform : Transform = camera.global_transform
	# Unset current state
	match current_state:
		GameState.SELECT:
			vehicle_select.set_display_hud(false)
	# Transitions to new state
	match target_state:
		GameState.SELECT:
			if _transforms_close(
				camera_transform,
				vehicle_select.wanted_transform(),
				MOVE_THRESHOLD):
					current_state = GameState.SELECT
					vehicle_select.set_display_hud(true)
			else:
				camera.global_transform = \
					camera_transform.interpolate_with(
						vehicle_select.wanted_transform(), 
						delta * MOVE_SPEED)

# - Follow the wanted camera target in VehicleSelect -
func _follow_camera_target() -> void:
	camera.global_transform = vehicle_select.wanted_transform()

# - Activates the vehicle select -
func select_vehicle() -> void:
	target_state = GameState.SELECT

# - If a transform is near of another -
func _transforms_close(a : Transform, b : Transform, threshold : float) -> bool:
	return (
		(a.basis.x - b.basis.x).length() < threshold
		and (a.basis.y - b.basis.y).length() < threshold
		and (a.basis.z - b.basis.z).length() < threshold
		and (a.origin  - b.origin).length()  < threshold
	)
