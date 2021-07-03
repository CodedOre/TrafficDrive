# Copyright 2021, Frederick Schenk

# --- VehicleData Script ---
# Provides the information about the vehicle

extends Resource
class_name VehicleData

# -- Constants --

# - Engine Defaults -
const DEFAULT_MAX_ENGINE_FORCE    : int   =     125
const DEFAULT_MAX_ENGINE_RPM      : int   =    6000
const DEFAULT_IDLE_ENGINE_RPM     : int   =    1000
const DEFAULT_ENGINE_POWER_CURVE  : Curve =    null

# Transmission Defaults
const DEFAULT_GEARS_IDENTIFIER    : Array = Array()
const DEFAULT_GEARS_RATIO         : Array = Array()
const DEFAULT_FINAL_DRIVE_RATIO   : int   =       1

# Additional Vehicle Defaults
const DEFAULT_MAX_BRAKE_FORCE     : int   =      16
const DEFAULT_MAX_STEER_ANGLE     : int   =      35
const DEFAULT_STEERING_WHEEL_MULT : int   =       8

# -- Properties --

# - Engine Properties -
export (int)           var MaxEngineForce          = DEFAULT_MAX_ENGINE_FORCE
export (int)           var MaxEngineRPM            = DEFAULT_MAX_ENGINE_RPM
export (int)           var IdleEngineRPM           = DEFAULT_IDLE_ENGINE_RPM
export (Curve)         var EnginePowerCurve        = DEFAULT_ENGINE_POWER_CURVE

# - Transmission Properties -
export (Array, String) var GearsIdentifier         = DEFAULT_GEARS_IDENTIFIER
export (Array, float)  var GearsRatio              = DEFAULT_GEARS_RATIO
export (float)         var FinalDriveRatio         = DEFAULT_FINAL_DRIVE_RATIO

# - Additional Vehicle Properties -
export (int)           var MaxBrakeForce           = DEFAULT_MAX_BRAKE_FORCE
export (int)           var MaxSteerAngle           = DEFAULT_MAX_STEER_ANGLE
export (int)           var SteeringWheelMultiplier = DEFAULT_STEERING_WHEEL_MULT

# -- Methods --

# - Sets the default values -
func _init(
	# Engine Properties
	_max_engine_force    : int   = DEFAULT_MAX_ENGINE_FORCE,
	_max_engine_rpm      : int   = DEFAULT_MAX_ENGINE_RPM,
	_idle_engine_rpm     : int   = DEFAULT_IDLE_ENGINE_RPM,
	_engine_power_curve  : Curve = DEFAULT_ENGINE_POWER_CURVE,
	# Transmission Properties
	_gears_identifier    : Array = DEFAULT_GEARS_IDENTIFIER,
	_gears_ratio         : Array = DEFAULT_GEARS_RATIO,
	_final_drive_ratio   : int   = DEFAULT_FINAL_DRIVE_RATIO,
	# Additional Vehicle Properties
	_max_brake_force     : int   = DEFAULT_MAX_BRAKE_FORCE,
	_max_steer_angle     : int   = DEFAULT_MAX_STEER_ANGLE,
	_steering_wheel_mult : int   = DEFAULT_STEERING_WHEEL_MULT
) -> void:
	# Engine Properties
	MaxEngineForce          = _max_engine_force
	MaxEngineRPM            = _max_engine_rpm
	IdleEngineRPM           = _idle_engine_rpm
	EnginePowerCurve        = _engine_power_curve
	# Transmission Properties
	GearsIdentifier         = _gears_identifier
	GearsRatio              = _gears_ratio
	FinalDriveRatio         = _final_drive_ratio
	# Additional Vehicle Properties
	MaxBrakeForce           = _max_brake_force
	MaxSteerAngle           = _max_steer_angle
	SteeringWheelMultiplier = _steering_wheel_mult
