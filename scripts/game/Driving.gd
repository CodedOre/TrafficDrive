# Copyright 2021, Frederick Schenk

# --- Driving Script ---
# The script for the actual driving scene.

extends Spatial

# -- Variables --

# - The car to be loaded -
var driven_vehicle_path : String

# - Internal nodes -
onready var spawnpoint  : Position3D = $PlayerSpawn
onready var gimbalcam   : Spatial    = $GimbalCamera
onready var vehicleinfo : Control    = $VehicleInfo
onready var outermirror : Control    = $OuterMirror
onready var pausescreen : Control    = $PauseScreen
onready var debugscreen : Control    = $DebugScreen

# - Runtime states -
var paused : bool = false

# -- Functions --

func _init(vehicle_path: String = ""):
	driven_vehicle_path = vehicle_path

# - Runs at startup -
func _ready() -> void:
	# Connect GameSettings
	GameSettings.connect("setting_changed", self, "_modify_settings")
	# Connect HUD elements
	pausescreen.connect("resume_action", self, "_toggle_pause")
	# Setup vehicle
	if driven_vehicle_path != null and driven_vehicle_path != "":
		setup_driving(driven_vehicle_path)
	else:
		push_error("Driving: Can't initialize without an path to a vehicle!")
		setup_driving("res://vehicles/scenes/Police.tscn")

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
	outermirror.visible = GameSettings.get_setting("Performance", "OuterMirrorActive")
	debugscreen.visible = GameSettings.get_setting("Meta", "DisplayDebugInfos")
	spawned_vehicle.Controlled = true
	spawned_vehicle.Running = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# - Runs every frame -
func _process(_delta) -> void:
	# Check for input to pause the game
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_pause()

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
	pausescreen.visible =   paused
	if GameSettings.get_setting("Performance", "OuterMirrorActive"):
		outermirror.visible = ! paused

# - Adapt to changed settings -
func _modify_settings() -> void:
	outermirror.visible = GameSettings.get_setting("Performance", "OuterMirrorActive")
	debugscreen.visible = GameSettings.get_setting("Meta", "DisplayDebugInfos")
