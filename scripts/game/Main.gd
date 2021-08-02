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
onready var camera : Camera = $MainCamera

# - Scene views -
onready var title_view : Position3D = $Views/TitleView

# - Menus -
onready var vehicle_select : Spatial = $Menus/VehicleSelect

# - Game Nodes -
onready var spawn  : Position3D = $PlayerSpawn
onready var gimbal : Spatial    = $Game/GimbalCamera
onready var tacho  : Control    = $Game/VehicleInfo
onready var debug  : Control    = $Game/DebugScreen

# - States of this scene -
var current_state = GameState.TITLE # GameState
var target_state  = GameState.TITLE # GameState

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	camera.global_transform = title_view.global_transform
	# Connect signals from VehicleSelect
	vehicle_select.connect("menu_return", self, "call_main_menu")
	vehicle_select.connect("menu_confirm", self, "drive_vehicle")
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
			vehicle_select.visible = false
	# Transitions to new state
	match target_state:
		GameState.SELECT:
			vehicle_select.visible = true
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
		GameState.DRIVE:
			current_state = GameState.DRIVE
			setup_driving_vehicle()

# - Follow the wanted camera target in VehicleSelect -
func _follow_camera_target() -> void:
	camera.global_transform = vehicle_select.wanted_transform()

# - Setups the vehicle which will be driven -
func setup_driving_vehicle() -> void:
	# Create new vehicle from selection
	var vehicle_path    : String      = vehicle_select.chosen_vehicle()
	var vehicle_scene   : PackedScene = load(vehicle_path)
	var spawned_vehicle : Vehicle     = vehicle_scene.instance()
	add_child(spawned_vehicle)
	# Setup instanced vehicle
	spawned_vehicle.global_transform = spawn.global_transform
	gimbal.set_vehicle(spawned_vehicle)
	tacho.set_displayed_vehicle(spawned_vehicle)
	debug.set_debug_vehicle(spawned_vehicle)
	# View the vehicle
	gimbal.make_current()
	debug.visible = true
	tacho.visible = true
	spawned_vehicle.Controlled = true
	spawned_vehicle.Running = true

# - Activates various states -
func call_main_menu() -> void:
	target_state = GameState.TITLE
func select_vehicle() -> void:
	target_state = GameState.SELECT
func drive_vehicle() -> void:
	target_state = GameState.DRIVE

# - If a transform is near of another -
func _transforms_close(a : Transform, b : Transform, threshold : float) -> bool:
	return (
		(a.basis.x - b.basis.x).length() < threshold
		and (a.basis.y - b.basis.y).length() < threshold
		and (a.basis.z - b.basis.z).length() < threshold
		and (a.origin  - b.origin).length()  < threshold
	)
