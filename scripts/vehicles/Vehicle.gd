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

# - The data for this vehicle -
export (Resource) var Data

# - NodePaths from the Vehicle -
export (Array, NodePath) onready var Lights
export (Array, NodePath) onready var Cameras
export        (NodePath) onready var OuterMirrorPoint
export        (NodePath) onready var SteeringWheel

# - States for the Vehicle -
export (bool) var Running     = false
export (bool) var Controlled  = false

# -- Variables --

# - State of the Vehicle -
var current_speed : int = 0

# - Internal objects -
var _light_manager  : VehicleLightsManager
var _light_nodes    : Array = Array()
var _camera_nodes   : Array = Array()
var _steer_wheel    : MeshInstance
var _traction_wheel : VehicleWheel

# - Camera variables -
var _camera_count : int
var _current_cam  : int
var _camera_point : CameraPoint

# - Mirror variables -
var _outer_mirror_point : CameraPoint

# - Input variables -
var _new_input    : bool   = false
var _input_engine : float  = 0.0
var _input_brake  : float  = 0.0
var _input_steer  : float  = 0.0

# - Steering variables -
var _steer_angle  : float  = 0.0
var _steer_delta  : float  = 0.0

# - Engine variables -
var _current_gear : int   = 1
var _current_mps  : int   = 0
var _engine_rpm   : int   = 0
var _ideal_rpm    : int   = 0
var _clutch_delta : float = 0.0

# -- Signals --

signal camera_changed()

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	# Check for VehicleData
	if VehicleData == null:
		push_error("Vehicle: Could not initialize vehicle without VehicleData!")
		return
	# Initialize VehicleLightManager
	for path in Lights:
		_light_nodes.append(get_node(path))
	_light_manager = VehicleLightsManager.new(self, _light_nodes)
	# Initialize Cameras
	for point in Cameras:
		var node = get_node(point)
		if node is CameraPoint and node != null:
			_camera_nodes.append(node)
	_camera_count = len(_camera_nodes)
	if _camera_count > 0:
		_current_cam = 0
		_camera_point = _camera_nodes[_current_cam]
	else:
		push_warning("Vehicle: No Cameras set for this vehicle!")
	# Initialize Mirrors
	if OuterMirrorPoint != null:
		_outer_mirror_point = get_node(OuterMirrorPoint)
	# Initialize Gears
	if Data.GearsIdentifier.size() != Data.GearsRatio.size():
		push_error("Vehicle: Gear Arrays not set up correctly!")
		return
	_current_gear = Data.GearsIdentifier.find("N")
	# Initialize additionial elements
	for child in get_children():
		if child is VehicleWheel:
			if child.use_as_traction == true:
				_traction_wheel = child
				break
	if SteeringWheel != null:
		_steer_wheel = get_node(SteeringWheel)

# - Runs at every frame -
func _physics_process(delta : float) -> void:
	_current_mps  = int(transform.basis.xform_inv(linear_velocity).z)
	if GameSettings.get_setting("Interface", "UseImperialUnits"):
		current_speed = int(_current_mps * 2.2369)
	else:
		current_speed = int(_current_mps * 3.6)
	if Controlled:
		_manage_input()
		_move_vehicle(delta)
		_animate_vehicle(delta)
		_inform_camera()

# - Checks input at every frame -
func _manage_input() -> void:
	_input_engine = 0.0
	_input_brake  = 0.0
	_input_steer  = 0.0
	
	# Input for Forward/Backward Movement
	if ! GameSettings.get_setting("Input", "SwitchGearsAutomatically"):
		# When driving with gears, we have a simplified input
		if Input.is_action_pressed("vehicle_movement_forward"):
			_input_engine = 1.0
		if Input.is_action_pressed("vehicle_movement_backward"):
			_input_brake  = 1.0
	else:
		# When driving with automatic, we change automatically forward and backwards
		if Input.is_action_just_pressed("vehicle_movement_forward") or \
			Input.is_action_just_pressed("vehicle_movement_backward"):
			_new_input = true
		var input_forward  : bool = Input.is_action_pressed("vehicle_movement_forward")
		var input_backward : bool = Input.is_action_pressed("vehicle_movement_backward")
		
		# Switch to the neutral gear if standing
		if _current_mps == 0 and ! input_forward and ! input_backward:
			_current_gear = Data.GearsIdentifier.find("N")
		
		if _new_input and _current_mps == 0:
			if input_forward:
				_current_gear = Data.GearsIdentifier.find("1")
				_input_engine = 1.0
			if input_backward:
				_current_gear = Data.GearsIdentifier.find("R")
				_input_engine = 1.0
		
		if input_forward and ! _new_input:
			if _current_mps > 0:
				_input_engine = 1.0
			else:
				_input_brake = 1.0
		
		if input_backward and ! _new_input:
			if _current_mps < 0:
				_input_engine = 1.0
			else:
				_input_brake = 1.0
	
	# If moving, disable new input
	if _current_mps != 0:
		_new_input = false
	
	# If standing, apply small value to brake to ensure the vehicle don't roll away
	if _current_mps == 0 and !_new_input and _input_brake == 0:
		_input_brake = 0.1
	
	# Input for Gear Switching
	if Input.is_action_just_pressed("vehicle_gear_up"):
		_current_gear = clamp(_current_gear + 1, 0, Data.GearsIdentifier.size() - 1)
		_clutch_delta = CLUTCH_SPEED
	if Input.is_action_just_pressed("vehicle_gear_down"):
		_current_gear = clamp(_current_gear - 1, 0, Data.GearsIdentifier.size() - 1)
		_clutch_delta = CLUTCH_SPEED
	
	# Input for Steering
	if Input.is_action_pressed("vehicle_movement_left"):
		_input_steer = 1.0
	if Input.is_action_pressed("vehicle_movement_right"):
		_input_steer = -1.0
	
	# Input for Camera
	if Input.is_action_just_pressed("vehicle_change_camera"):
		_current_cam = (_current_cam + 1) % _camera_count
		_camera_point = _camera_nodes[_current_cam]
		emit_signal("camera_changed")
	
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
func _move_vehicle(delta : float) -> void:
	# Calculate clutch factor
	_clutch_delta = max(0.0, _clutch_delta - delta)
	var clutch_factor : int   = 1 if _clutch_delta == 0 else 0
	
	# Calculate RPM using the wheels
	var rpm_min_clamp        : int   = Data.IdleEngineRPM if Running else 0
	var wheel_circumference  : float = 2.0 * PI * _traction_wheel.wheel_radius
	var wheel_rotation_speed : float = 60.0 * _current_mps / wheel_circumference
	var drive_rotation_speed : float = wheel_rotation_speed * Data.FinalDriveRatio
	var calculated_rpm       : float = drive_rotation_speed * Data.GearsRatio[_current_gear]
	_engine_rpm = clamp(calculated_rpm, rpm_min_clamp, Data.MaxEngineRPM)
	
	# Calculate Engine Force
	var rpm_factor    : float = clamp(float(_engine_rpm) / float(Data.MaxEngineRPM), 0.0, 1.0)
	var power_factor  : float = Data.EnginePowerCurve.interpolate_baked(rpm_factor)
	
	engine_force = clutch_factor * _input_engine \
					* power_factor * Data.GearsRatio[_current_gear] \
					* Data.FinalDriveRatio * Data.MaxEngineForce
	
	# When automatic, select gears according to the power_factor
	
	# When moving backwards, activate reverse lights
	if engine_force < 0:
		_light_manager.ReverseLights = true
	else:
		_light_manager.ReverseLights = false
	
	# Apply the brakes
	brake = _input_brake * Data.MaxBrakeForce
	if _input_brake > 0.12:
		_light_manager.BrakeLights = true
	else:
		_light_manager.BrakeLights = false
	
	# Steer the vehicle
	var steer_target : float = _input_steer * Data.MaxSteerAngle
	steer_target = dectime(steer_target, abs(_current_mps), 0.034)
	if steer_target < _steer_angle:
		_steer_angle -= STEER_SPEED * delta
		if steer_target > _steer_angle:
			_steer_angle = steer_target
	if steer_target > _steer_angle:
		_steer_angle += STEER_SPEED * delta
		if steer_target < _steer_angle:
			_steer_angle = steer_target
	steering = deg2rad(_steer_angle)

# - Animates some parts of the vehicle -
func _animate_vehicle(delta : float) -> void:
	if _steer_wheel != null:
		var wheel_rotate : Vector3 = _steer_wheel.rotation_degrees
		var rotation_tgt : float   = -1 * _steer_angle * Data.SteeringWheelMultiplier
		var interpol_rot : float   = wheel_rotate.z + (rotation_tgt - wheel_rotate.z) * delta * 4
		wheel_rotate.z = interpol_rot
		_steer_wheel.rotation_degrees = wheel_rotate

# - Informs GimbalCamera over CameraPoint about certain states -
func _inform_camera() -> void:
	if _camera_point != null:
		# Send Vehicle data
		_camera_point.point_speed = _current_mps
		_camera_point.point_steer = steering
		# Send Camera state request
		if _current_mps > 0:
			_camera_point.state_request = CameraPoint.RequestState.RESET
		elif _current_mps < 0:
			_camera_point.state_request = CameraPoint.RequestState.BEHIND
		else:
			_camera_point.state_request = CameraPoint.RequestState.NONE
