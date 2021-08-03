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
onready var debugscreen : Control    = $DebugScreen

# - Runtime states -
var paused : bool = false

# -- Functions --

func _init(vehicle_path: String = ""):
	driven_vehicle_path = vehicle_path

# - Runs at startup -
func _ready() -> void:
	if driven_vehicle_path != null and driven_vehicle_path != "":
		setup_driving(driven_vehicle_path)
	else:
		push_error("Driving: Can't initialize without an path to a vehicle!")
		setup_driving("res://vehicles/scenes/Police.tscn")

func setup_driving(vehicle_path: String):
	if vehicle_path == null or vehicle_path == "":
		push_error("Driving: Can't initialize without an path to a vehicle!")
	# Load the selected vehicle
	var vehicle_scene   : PackedScene = load(vehicle_path)
	var spawned_vehicle : Vehicle     = vehicle_scene.instance()
	add_child(spawned_vehicle)
	# Setup nodes
	spawned_vehicle.global_transform = spawnpoint.global_transform
	gimbalcam.set_vehicle(spawned_vehicle)
	vehicleinfo.set_displayed_vehicle(spawned_vehicle)
	debugscreen.set_debug_vehicle(spawned_vehicle)
	# Make scene ready for playing
	gimbalcam.make_current()
	debugscreen.visible = GameSettings.get_setting("Meta", "DisplayDebugInfos")
	spawned_vehicle.Controlled = true
	spawned_vehicle.Running = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# - Runs every frame -
func _process(_delta):
	# Check for input to pause the game
	if Input.is_action_just_pressed("ui_cancel"):
		paused = ! paused
		_manage_pause()

# - Manages the pause -
func _manage_pause():
	# Set mouse capture
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Pause the tree and show the menu
	get_tree().paused = paused
