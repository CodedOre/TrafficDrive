# Copyright 2021, Frederick Schenk

# --- Vehicle Script ---
# The main script for a vehicle.

extends VehicleBody
class_name Vehicle

# -- Properties --

# - NodePaths from the vehicle -
export (Array, NodePath) onready var Lights
export (NodePath)        onready var Camera
export (bool)                    var Controlled

# -- Variables --

# - Internal objects -
var _light_manager : VehicleLightsManager
var _light_nodes   : Array = Array()
var _camera_node   : CameraPoint

# -- Functions --

# - Runs at startup -
func _ready():
	# Initialize VehicleLightManager
	for path in Lights:
		_light_nodes.append(get_node(path))
	_light_manager = VehicleLightsManager.new(self, _light_nodes)
	_camera_node = get_node(Camera)

# - Runs at every frame -
func _physics_process(_delta : float):
	if Controlled:
		_manage_input()

# - Checks input at every frame -
func _manage_input():
	# Input for Nightlights
	if Input.is_action_just_pressed("vehicle_nightlight_toggle"):
		match _light_manager.NightLights:
			VehicleLightsManager.NightLightMode.OFF:
				_light_manager.NightLights = VehicleLightsManager.NightLightMode.ON
			VehicleLightsManager.NightLightMode.ON:
				_light_manager.NightLights = VehicleLightsManager.NightLightMode.FAR
			VehicleLightsManager.NightLightMode.FAR:
				_light_manager.NightLights = VehicleLightsManager.NightLightMode.OFF
