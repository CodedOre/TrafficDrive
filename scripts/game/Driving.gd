# Copyright 2021, Frederick Schenk

# --- Driving Script ---
# The script for the actual driving scene.

extends GameState

# -- Variables --

# - The driven vehicle -
var driven_vehicle : Vehicle

# - Internal nodes -
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
signal check_pause()
signal return_to_main()

# -- Functions --

# - Sets up the driven vehicle -
func setup_driving(vehicle_path: String, paint: int, spawn: Transform) -> void:
	if vehicle_path == null or vehicle_path == "":
		push_error("Driving: Can't initialize without an path to a vehicle!")
	# Load the selected vehicle
	var vehicle_scene   : PackedScene = load(vehicle_path)
	driven_vehicle = vehicle_scene.instance()
	add_child(driven_vehicle)
	# Setup nodes
	driven_vehicle.pause_mode = PAUSE_MODE_STOP
	driven_vehicle.VehiclePaint = paint
	driven_vehicle.global_transform = spawn
	gimbalcam.set_vehicle(driven_vehicle)
	outermirror.set_displayed_vehicle(driven_vehicle)
	vehicleinfo.set_displayed_vehicle(driven_vehicle)
	debugscreen.set_debug_vehicle(driven_vehicle)
	# Make scene ready for playing
	gimbalcam.make_current()
	driven_vehicle.Controlled = true
	driven_vehicle.Running = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# - Check for input to pause the game -
func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if ! submenud:
			_toggle_pause()
		if submenud and ! settingmenu.visible:
			submenud = false

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
	# Pause Camera input
	gimbalcam.set_process_input(! paused)
	# Change visibility of HUD elements
	vehicleinfo.visible = ! paused
	outermirror.visible = ! paused
	debugscreen.visible = ! paused
	pausescreen.visible =   paused
	backdrop.visible    =   paused
	emit_signal("check_pause")

# - Displays the settings menu -
func _open_options():
	submenud = true
	pausescreen.visible = false
	settingmenu.visible = true
	settingmenu.ParseInput = true

# - Returns to pause menu from options -
func _close_options():
	settingmenu.ParseInput = false
	settingmenu.visible = false
	pausescreen.visible = true

# - Emit signals for other scripts to carry on -
func _close_to_main() -> void:
	# De-Pause (for the next load-in)
	_toggle_pause()
	# Clear the vehicle from the tree
	var clear_vehicle : Vehicle = driven_vehicle
	driven_vehicle = null
	gimbalcam.set_vehicle(null)
	outermirror.set_displayed_vehicle(null)
	vehicleinfo.set_displayed_vehicle(null)
	debugscreen.set_debug_vehicle(null)
	clear_vehicle.queue_free()
	# Return to the main menu
	emit_signal("return_to_main")
