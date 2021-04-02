# Copyright 2021, Frederick Schenk

# --- Vehicle Script ---
# The main script for a vehicle.

extends VehicleBody
class_name Vehicle

# -- Constants --

# - Properties for a Vehicle -
const STEER_SPEED : int = 60

# -- Properties --

# - Properties of this Vehicle -
export (int) var MaxEngineForce = 250
export (int) var MaxBrakeForce  =   8
export (int) var MaxSteerAngle  =  35

# - NodePaths from the Vehicle -
export (Array, NodePath) onready var Lights
export (NodePath)        onready var Camera
export (bool)                    var Controlled

# -- Variables --

# - State of the Vehicle -
var current_speed : int = 0

# - Internal objects -
var _light_manager : VehicleLightsManager
var _light_nodes   : Array = Array()
var _camera_node   : CameraPoint

# - Runtime variables -
var _new_input    : bool  = false
var _steer_angle  : float = 0.0
var _steer_delta  : float = 0.0
var _input_engine : float = 0.0
var _input_brake  : float = 0.0
var _input_steer  : float = 0.0

# -- Functions --

# - Runs at startup -
func _ready():
	# Initialize VehicleLightManager
	for path in Lights:
		_light_nodes.append(get_node(path))
	_light_manager = VehicleLightsManager.new(self, _light_nodes)
	_camera_node = get_node(Camera)

# - Runs at every frame -
func _physics_process(delta : float):
	current_speed = int(transform.basis.xform_inv(linear_velocity).z * 3.6)
	if Controlled:
		_manage_input()
		_move_vehicle(delta)
		_inform_camera()

# - Checks input at every frame -
func _manage_input():
	_input_engine = 0.0
	_input_brake  = 0.0
	_input_steer  = 0.0
	# Input for Forward/Backward Movement
	if Input.is_action_just_pressed("vehicle_movement_forward"):
		_new_input = true
	if Input.is_action_pressed("vehicle_movement_forward"):
		if current_speed == 0 and _new_input:
			_input_engine = 1.0
		elif current_speed > 0:
			_input_engine = 1.0
		elif current_speed <= 0:
			_input_brake = 1.0
	
	if Input.is_action_just_pressed("vehicle_movement_backward"):
		_new_input = true
	if Input.is_action_pressed("vehicle_movement_backward"):
		if current_speed == 0 and _new_input:
			_input_engine = -1.0
		elif current_speed < 0:
			_input_engine = -1.0
		elif current_speed >= 0:
			_input_brake = 1.0
	
	# If moving, disable new input
	if current_speed != 0:
		_new_input = false
	
	# If standing, apply small value to brake to ensure the vehicle don't roll away
	if current_speed == 0 and !_new_input:
		_input_brake = 0.1
	
	# Input for Steering
	if Input.is_action_pressed("vehicle_movement_left"):
		_input_steer = 1.0
	if Input.is_action_pressed("vehicle_movement_right"):
		_input_steer = -1.0
	
	# Input for Nightlights
	if Input.is_action_just_pressed("vehicle_light_night"):
		match _light_manager.NightLights:
			VehicleLightsManager.NightLightMode.OFF:
				_light_manager.NightLights = VehicleLightsManager.NightLightMode.ON
			VehicleLightsManager.NightLightMode.ON:
				_light_manager.NightLights = VehicleLightsManager.NightLightMode.FAR
			VehicleLightsManager.NightLightMode.FAR:
				_light_manager.NightLights = VehicleLightsManager.NightLightMode.OFF
	
	# Input for Turn Signals
	if Input.is_action_just_pressed("vehicle_light_turn_left"):
		_light_manager.TurnLeftLights = ! _light_manager.TurnLeftLights
	if Input.is_action_just_pressed("vehicle_light_turn_right"):
		_light_manager.TurnRightLights = ! _light_manager.TurnRightLights

# - Move the vehicle according to input -
func _move_vehicle(delta : float):
	# Move the vehicle
	engine_force = _input_engine * MaxEngineForce
	
	# When moving backwards, activate reverse lights
	if _input_engine < 0:
		_light_manager.ReverseLights = true
	else:
		_light_manager.ReverseLights = false
	
	# Apply the brakes
	brake = _input_brake * MaxBrakeForce
	if _input_brake > 0.12:
		_light_manager.BrakeLights = true
	else:
		_light_manager.BrakeLights = false
	
	# Steer the vehicle
	var steer_target : float = _input_steer * MaxSteerAngle
	steer_target = dectime(steer_target, abs(current_speed), 0.125)
	if steer_target < _steer_angle:
		_steer_angle -= STEER_SPEED * delta
		if steer_target > _steer_angle:
			_steer_angle = steer_target
	if steer_target > _steer_angle:
		_steer_angle += STEER_SPEED * delta
		if steer_target < _steer_angle:
			_steer_angle = steer_target
	steering = deg2rad(_steer_angle)

# - Informs GimbalCamera over CameraPoint about certain states -
func _inform_camera():
	# Send Vehicle data
	_camera_node.point_speed = current_speed
	_camera_node.point_steer = _steer_angle
	# Send Camera state request
	if current_speed > 0:
		_camera_node.state_request = CameraPoint.RequestState.RESET
	elif current_speed < 0:
		_camera_node.state_request = CameraPoint.RequestState.BEHIND
	else:
		_camera_node.state_request = CameraPoint.RequestState.NONE
