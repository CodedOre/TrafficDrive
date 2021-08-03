# Copyright 2021, Frederick Schenk

# --- Driving Script ---
# The script for the actual driving scene.

extends Spatial

# -- Variables --

# - Internal nodes -
onready var spawnpoint  : Position3D = $PlayerSpawn
onready var gimbalcam   : Spatial    = $GimbalCamera
onready var vehicleinfo : Control    = $VehicleInfo
onready var debugscreen : Control    = $DebugScree
onready var driven_car  : Vehicle

# -- Functions --

# - Initializes the scene -
func _init(vehicle_path: String) -> void:
	# Load the selected vehicle
	var vehicle_scene   : PackedScene = load(vehicle_path)
	var spawned_vehicle : Vehicle     = vehicle_scene.instance()
	add_child(spawned_vehicle)
	driven_car = spawned_vehicle

# - Runs at startup -
func _ready() -> void:
	# Setup nodes
	driven_car.global_transform = spawnpoint.global_transform
	gimbalcam.set_vehicle(driven_car)
	vehicleinfo.set_displayed_vehicle(driven_car)
	debugscreen.set_debug_vehicle(driven_car)
	# Make scene ready for playing
	gimbalcam.make_current()
	debugscreen.visible = GameSettings.get_setting("Meta", "DisplayDebugInfos")
	driven_car.Controlled = true
	driven_car.Running = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
