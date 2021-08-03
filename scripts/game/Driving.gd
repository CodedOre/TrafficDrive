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

# -- Functions --

func _init(vehicle_path: String):
	driven_vehicle_path = vehicle_path

# - Runs at startup -
func _ready() -> void:
	if driven_vehicle_path != null:
		setup_driving(driven_vehicle_path)

func setup_driving(vehicle_path: String):
	if vehicle_path == null:
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
