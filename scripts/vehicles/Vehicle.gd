# Copyright 2021, Frederick Schenk

# --- Vehicle Script ---
# The main script for a vehicle.

extends VehicleBody
class_name Vehicle

# -- Enums --

# - Gear State -
enum GearState {NONE, CLUTCH_OFF, GEAR_SWITCH, CLUTCH_ON}

# -- Constants --

# - Properties for a Vehicle -
const STEER_SPEED         : int   = 60
const CLUTCH_SPEED        : float =  0.25
const CLUTCH_DELTA_FACTOR : float =  8.0
const MIN_CRUISE_SPEED    : int   = 25

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
var current_speed  : float = 0.0
var _current_mps   : float = 0
var _engine_rpm    : int   = 0

# - Internal objects -
var _light_manager  : VehicleLightsManager
var _pid_controller : PIDController
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
var _new_input     : bool   = false
var _input_engine  : float  = 0.0
var _input_brake   : float  = 0.0
var _input_steer   : float  = 0.0

# - Steering variables -
var _steer_angle   : float  = 0.0
var _steer_delta   : float  = 0.0

# - Gear variables -
var _current_gear  : int   = 1
var _gear_target   : int   = 1
var _gear_state            = GearState.NONE
var _gear_delta    : float = 0.0
var _gear_start    : bool  = false
var _clutch_factor : float = 0.0

# - Cruise control variables -
var _cruise_speed  : int   = 0
var _cruise_active : bool  = false
var _pid_gains     : Vector3 = Vector3(1.0, 0.5, 0.5)

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
	_pid_controller = PIDController.new()

# - Runs at every frame -
func _physics_process(delta : float) -> void:
	_current_mps  = stepify(transform.basis.xform_inv(linear_velocity).z, 0.001)
	if GameSettings.get_setting("Interface", "UseImperialUnits"):
		current_speed = _current_mps * 2.2369
	else:
		current_speed = _current_mps * 3.6
	if Controlled and Running:
		_manage_input()
		_cruise_control()
		_calculate_power(delta)
		_move_vehicle(delta)
		_animate_vehicle(delta)
		_inform_camera()

# - Checks input at every frame -
func _manage_input() -> void:
	_input_engine = 0.0
	_input_brake  = 0.0
	_input_steer  = 0.0
	
	# Use a rounded speed for input calculations
	var rounded_mps    : float = round(_current_mps)
	
	# Input for Forward/Backward Movement
	var input_forward  : bool  = Input.is_action_pressed("vehicle_movement_forward")
	var input_backward : bool  = Input.is_action_pressed("vehicle_movement_backward")
	if ! GameSettings.get_setting("Input", "SwitchGearsAutomatically"):
		# When driving with gears, we have a simplified input
		var reverse_gear : bool = _current_gear == Data.GearsIdentifier.find("R")
		if (input_forward and !reverse_gear) \
			or (input_backward and reverse_gear):
				_input_engine = 1.0
		if (input_backward and !reverse_gear) \
			or (input_forward and reverse_gear):
				_input_brake  = 1.0
	else:
		# When driving with automatic, we change automatically forward and backwards
		if Input.is_action_just_pressed("vehicle_movement_forward") or \
			Input.is_action_just_pressed("vehicle_movement_backward"):
			_new_input = true
		
		# Switch to the neutral gear if standing
		if rounded_mps == 0 and ! input_forward and ! input_backward and ! _new_input:
			_gear_target = Data.GearsIdentifier.find("N")
			_gear_state  = GearState.CLUTCH_OFF
			_gear_delta = CLUTCH_SPEED
		
		# When standing, switch to the gear for the wanted direction
		if _new_input and rounded_mps == 0 and ! _gear_start:
			if input_forward:
				_gear_target = Data.GearsIdentifier.find("1")
				_gear_state  = GearState.CLUTCH_OFF
				_gear_delta = CLUTCH_SPEED
				_input_engine = 1.0
				_gear_start = true
			if input_backward:
				_gear_target = Data.GearsIdentifier.find("R")
				_gear_state  = GearState.CLUTCH_OFF
				_gear_delta = CLUTCH_SPEED
				_input_engine = 1.0
				_gear_start = true
		
		if _gear_start:
			_input_engine = 1.0
		
		# Manage engine/brake power according to the direction
		if input_forward and ! _new_input:
			if rounded_mps > 0:
				_input_engine = 1.0
			else:
				_input_brake = 1.0
		if input_backward and ! _new_input:
			if rounded_mps < 0:
				_input_engine = 1.0
			else:
				_input_brake = 1.0
		
		# Switch gears according to the RPM
		if _gear_state == GearState.NONE:
			if Data.GearsIdentifier.size() - 1 > _current_gear \
				and _current_gear >= Data.GearsIdentifier.find("1"):
					if _engine_rpm > Data.MaxEngineRPM - 1000:
						_gear_target = clamp(_current_gear + 1, 0, Data.GearsIdentifier.size() - 1)
						_gear_state  = GearState.CLUTCH_OFF
						_gear_delta = CLUTCH_SPEED
			if _current_gear > Data.GearsIdentifier.find("1"):
				if _engine_rpm < Data.IdleEngineRPM + 1000:
					_gear_target = clamp(_current_gear - 1, 0, Data.GearsIdentifier.size() - 1)
					_gear_state  = GearState.CLUTCH_OFF
					_gear_delta = CLUTCH_SPEED
	
	# Deactivate cruise control when braking or accelerating
	if input_forward or input_backward:
		_cruise_active = false
	
	# If moving, disable new input
	if rounded_mps != 0:
		_gear_start = false
		_new_input = false
	
	# If standing, apply small value to brake to ensure the vehicle don't roll away
	if rounded_mps == 0 and !_new_input and _input_brake == 0:
		_input_brake = 0.1
	
	# Input for Gear Switching
	if _gear_state == GearState.NONE:
		if Input.is_action_just_pressed("vehicle_gear_up"):
			if _current_gear < Data.GearsIdentifier.size() - 1:
				_gear_target = _current_gear + 1
				_gear_state  = GearState.CLUTCH_OFF
				_gear_delta = CLUTCH_SPEED
		if Input.is_action_just_pressed("vehicle_gear_down"):
			if _current_gear > 0:
				_gear_target = _current_gear - 1
				_gear_state  = GearState.CLUTCH_OFF
				_gear_delta = CLUTCH_SPEED
	
	# Input for Cruise Control
	if Input.is_action_just_pressed("vehicle_set_cruise_control"):
		if ! _cruise_active and current_speed > MIN_CRUISE_SPEED:
			_cruise_active = true
			_cruise_speed = stepify(current_speed, 5)
		else:
			_cruise_active = false
	
	if Input.is_action_just_pressed("vehicle_increase_cruise_control"):
		_cruise_speed = max(MIN_CRUISE_SPEED, _cruise_speed + 5)
	
	if Input.is_action_just_pressed("vehicle_decrease_cruise_control"):
		_cruise_speed = max(MIN_CRUISE_SPEED, _cruise_speed - 5)
	
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

# - Set's the vehicle throttle to keep a certain speed -
func _cruise_control() -> void:
	if _cruise_active:
		var cruise_delta : float = _cruise_speed - current_speed + 1
		var cruise_input : float = _pid_controller.get_pid_output(_pid_gains, cruise_delta)
		_input_engine = clamp(cruise_input, 0, 1)

# - Calculate the engine power -
func _calculate_power(delta: float) -> void:
	# Simulate Gear Switching
	if _gear_delta != 0:
		_gear_delta = max(0.0, _gear_delta - delta)
	if _gear_delta == 0:
		match _gear_state:
			GearState.CLUTCH_OFF:
				_gear_state = GearState.GEAR_SWITCH
				_gear_delta = CLUTCH_SPEED
			GearState.GEAR_SWITCH:
				_gear_state = GearState.CLUTCH_ON
				_gear_delta = CLUTCH_SPEED
			GearState.CLUTCH_ON:
				_gear_state = GearState.NONE
	match _gear_state:
		GearState.NONE:
			_clutch_factor = 1
		GearState.CLUTCH_OFF:
			_clutch_factor = max(0.0, _clutch_factor - 1.0 * delta * CLUTCH_DELTA_FACTOR)
		GearState.GEAR_SWITCH:
			_clutch_factor = 0
			_current_gear = _gear_target
		GearState.CLUTCH_ON:
			_clutch_factor = min(_clutch_factor + 1.0 * delta * CLUTCH_DELTA_FACTOR, 1.0)
	
	# Determine target RPM
	var target_rpm : int = 0
	if _current_gear == Data.GearsIdentifier.find("N"):
		# When in neutral gear, define RPM according to engine input.
		target_rpm = max(Data.IdleEngineRPM, _input_engine * (Data.MaxEngineRPM - 1000))
	else:
		# Normally, calculate RPM using the wheels
		var rpm_min_clamp        : int   = Data.IdleEngineRPM if Running else 0
		var wheel_circumference  : float = 2.0 * PI * _traction_wheel.wheel_radius
		var wheel_rotation_speed : float = 60.0 * _current_mps / wheel_circumference
		var drive_rotation_speed : float = wheel_rotation_speed * Data.FinalDriveRatio
		var calculated_rpm       : float = drive_rotation_speed * Data.GearsRatio[_current_gear]
		target_rpm = clamp(calculated_rpm, rpm_min_clamp, Data.MaxEngineRPM + 100)
	
	# Interpolate RPM to the target
	_engine_rpm = _engine_rpm + (target_rpm - _engine_rpm) * (delta * 2)
	
	# Calculate Engine Force
	var rpm_factor    : float = float(_engine_rpm) / float(Data.MaxEngineRPM)
	var power_factor  : float = Data.EnginePowerCurve.interpolate_baked(rpm_factor)
	
	engine_force = _clutch_factor * _input_engine \
					* power_factor * Data.GearsRatio[_current_gear] \
					* Data.FinalDriveRatio * Data.MaxEngineForce

# - Move the vehicle according to input -
func _move_vehicle(delta : float) -> void:
	# When in reverse, activate reverse lights
	_light_manager.ReverseLights = _current_gear == Data.GearsIdentifier.find("R")
	
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
		var rounded_mps : float = round(_current_mps)
		
		# Send Vehicle data
		_camera_point.point_speed = rounded_mps
		_camera_point.point_steer = steering
		# Send Camera state request
		if rounded_mps > 0:
			_camera_point.state_request = CameraPoint.RequestState.RESET
		elif rounded_mps < 0:
			_camera_point.state_request = CameraPoint.RequestState.BEHIND
		else:
			_camera_point.state_request = CameraPoint.RequestState.NONE
