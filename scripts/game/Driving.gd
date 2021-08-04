# Copyright 2021, Frederick Schenk

# --- Driving Script ---
# The script for the actual driving scene.

extends GameState

# -- Variables --

# - Internal nodes -
onready var spawnpoint  : Position3D = $PlayerSpawn
onready var gimbalcam   : Spatial    = $GimbalCamera
onready var vehicleinfo : Control    = $VehicleInfo
onready var outermirror : Control    = $OuterMirror
onready var backdrop    : Control    = $PauseBackdrop
onready var pausescreen : Control    = $PauseScreen
onready var settingmenu : Control    = $SettingsMenu
onready var debugscreen : Control    = $DebugScreen

# - Runtime states -
var submenud : bool = false
var paused   : bool = false

# -- Signals --
signal return_to_main()

# -- Functions --

# - Sets up the driven vehicle -
func setup_driving(vehicle_path: String) -> void:
	if vehicle_path == null or vehicle_path == "":
		push_error("Driving: Can't initialize without an path to a vehicle!")
	# Load the selected vehicle
	var vehicle_scene   : PackedScene = load(vehicle_path)
	var spawned_vehicle : Vehicle     = vehicle_scene.instance()
	add_child(spawned_vehicle)
	# Setup nodes
	spawned_vehicle.global_transform = spawnpoint.global_transform
	gimbalcam.set_vehicle(spawned_vehicle)
	outermirror.set_displayed_vehicle(spawned_vehicle)
	vehicleinfo.set_displayed_vehicle(spawned_vehicle)
	debugscreen.set_debug_vehicle(spawned_vehicle)
	# Make scene ready for playing
	gimbalcam.make_current()
	spawned_vehicle.Controlled = true
	spawned_vehicle.Running = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# - Runs every frame -
func _process(_delta) -> void:
	# Check for input to pause the game
	if Input.is_action_just_pressed("ui_cancel"):
		if ! submenud:
			_toggle_pause()
		else:
			_close_options()

# - Manages the pause -
func _toggle_pause() -> void:
	paused = ! paused
	# Set mouse capture
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Pause the tree
	get_tree().paused   =   paused
	# Change visibility of HUD elements
	vehicleinfo.visible = ! paused
	outermirror.visible = ! paused
	debugscreen.visible = ! paused
	pausescreen.visible =   paused
	backdrop.visible    =   paused

# - Displays the settings menu -
func _open_options():
	submenud = true
	pausescreen.visible = false
	settingmenu.visible = true

# - Returns to pause menu from options -
func _close_options():
	submenud = false
	settingmenu.visible = false
	pausescreen.visible = true

# - Emit signals for other scripts to carry on -
func _close_to_main() -> void:
	emit_signal("return_to_main")
