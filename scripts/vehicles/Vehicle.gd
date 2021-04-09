# Copyright 2021, Frederick Schenk

# --- Vehicle Script ---
# The main script for a vehicle.

extends VehicleBody
class_name Vehicle

# -- Constants --

# - Properties for a Vehicle -
const STEER_SPEED  : int   = 60
const CLUTCH_SPEED : float =  0.75

# -- Properties --

# - Engine Properties -
export (int)           var MaxEngineForce   =  125
export (int)           var MaxEngineRPM     = 6000
export (int)           var IdleEngineRPM    = 1000
export (int)           var RPMVelocity      =  500
export (Curve)         var EnginePowerCurve

# - Transmission Properties -
export (Array, String) var GearsIdentifier  = Array()
export (Array, float)  var GearsRatio       = Array()
export (float)         var FinalDriveRatio  = 0

# - Additional Vehicle Properties -
export (int)           var MaxBrakeForce    =    8
export (int)           var MaxSteerAngle    =   35

# - NodePaths from the Vehicle -
export (Array, NodePath) onready var Lights
export (NodePath)        onready var Camera

# - States for the Vehicle -
export (bool) var Running    = false
export (bool) var Controlled = false

# -- Variables --

# - State of the Vehicle -
var current_speed : int = 0

# - Internal objects -
var _light_manager : VehicleLightsManager
var _light_nodes   : Array = Array()
var _camera_node   : CameraPoint

# - Input variables -
var _new_input    : bool   = false
var _input_engine : float  = 0.0
var _input_brake  : float  = 0.0
var _input_steer  : float  = 0.0

# - Steering variables -
var _steer_angle  : float  = 0.0
var _steer_delta  : float  = 0.0

# - Engine variables -
var _current_gear : int   = 0
var _engine_rpm   : int   = 0
var _clutch_delta : float = 0.0

# -- Functions --

# - Runs at startup -
func _ready():
	# Initialize VehicleLightManager
	for path in Lights:
		_light_nodes.append(get_node(path))
	_light_manager = VehicleLightsManager.new(self, _light_nodes)
	# Initialize Camera
	_camera_node = get_node(Camera)
	# Initialize Gears
	if GearsIdentifier.size() != GearsRatio.size():
		push_error("Vehicle: Gear Arrays not set up correctly!")
		return
	_current_gear = GearsIdentifier.find("N")

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
	if current_speed == 0 and !_new_input and _input_brake == 0:
		_input_brake = 0.1
	
	# Input for Gear Switching
	if Input.is_action_just_pressed("vehicle_gear_up"):
		_current_gear = clamp(_current_gear + 1, 0, GearsIdentifier.size() - 1)
		_clutch_delta = CLUTCH_SPEED
	if Input.is_action_just_pressed("vehicle_gear_down"):
		_current_gear = clamp(_current_gear - 1, 0, GearsIdentifier.size() - 1)
		_clutch_delta = CLUTCH_SPEED
	
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
		_light_manager.TurnLeftLights  = ! _light_manager.TurnLeftLights
		_light_manager.TurnRightLights = false
	if Input.is_action_just_pressed("vehicle_light_turn_right"):
		_light_manager.TurnLeftLights  = false
		_light_manager.TurnRightLights = ! _light_manager.TurnRightLights
	if Input.is_action_just_pressed("vehicle_light_hazards"):
		_light_manager.HazardsLights = ! _light_manager.HazardsLights

# - Move the vehicle according to input -
func _move_vehicle(delta : float):
	# Calculate clutch factor
	_clutch_delta = max(0.0, _clutch_delta - delta)
	var clutch_factor : int   = 1 if _clutch_delta == 0 else 0
	
	# Calculate the Engine RPM
	var rpm_target : int = 0
	if abs(_input_engine) > 0:
		rpm_target = MaxEngineRPM
	elif Running:
		rpm_target = IdleEngineRPM
	if _engine_rpm < rpm_target:
		var rpm_acent = _engine_rpm + RPMVelocity * delta
		_engine_rpm = min(rpm_acent, rpm_target)
	else:
		var rpm_decent : int = _engine_rpm - RPMVelocity * delta
		_engine_rpm = max(rpm_decent, rpm_target)
		
	# Calculate Engine Force
	var rpm_factor    : float = clamp(float(_engine_rpm) / float(MaxEngineRPM), 0.0, 1.0)
	var power_factor  : float = EnginePowerCurve.interpolate_baked(rpm_factor)
	
	engine_force = clutch_factor * _input_engine * power_factor * GearsRatio[_current_gear] * FinalDriveRatio * MaxEngineForce
	
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
