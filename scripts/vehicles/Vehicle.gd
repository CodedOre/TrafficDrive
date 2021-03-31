# Copyright 2021, Frederick Schenk

# --- Vehicle Script ---
# The main script for a vehicle.

extends VehicleBody
class_name Vehicle

# -- Properties --

# - NodePaths from the vehicle -
export (Array, NodePath) onready var Lights
export (NodePath)        onready var Camera

# -- Variables --

# - Internal objects -
var _light_manager : VehicleLightsManager
var _light_nodes   : Array = Array()
var _camera_node   : CameraPoint

# -- Functions --

# - Run at startup -
func _ready():
	# Initialize VehicleLightManager
	for path in Lights:
		_light_nodes.append(get_node(path))
	_light_manager = VehicleLightsManager.new(self, _light_nodes)
	_camera_node = get_node(Camera)
