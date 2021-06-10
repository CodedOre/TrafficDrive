# Copyright 2021, Frederick Schenk

# --- VehicleInfo Script ---
# Shows information about the vehicle.

extends MarginContainer

# -- Constants --

# - RPM Range constant -
const MAX_DISPLAYED_RPM : int = 8000

# - Needle contants -
const MIN_NEEDLE_DEGREE : int = -125
const MAX_NEEDLE_DEGREE : int =  125

# -- Properties --

var DisplayedVehicle : Vehicle setget set_debug_vehicle, get_debug_vehicle

# -- Variables --

# - Internal nodes -
onready var _speed_field : Label           = $Background/SpeedValue
onready var _gear_field  : Label           = $Background/GearValue
onready var _rpm_range   : TextureProgress = $RPMRange
onready var _rpm_needle  : TextureRect     = $Needle

# - Runtime variables -
var _vehicle_connected : bool
var _displayed_vehicle : Vehicle

# -- Functions --

# - Runs at every frame -
func _physics_process(_delta):
	if _displayed_vehicle != null:
		# Update text fields
		_speed_field.text = str(_displayed_vehicle.current_speed)
		_gear_field.text  = _displayed_vehicle.GearsIdentifier[_displayed_vehicle._current_gear]
		
		# Update RPM needle
		var vehicle_rpm  : float = float(_displayed_vehicle._engine_rpm)
		var rpm_ratio    : float = vehicle_rpm / float(MAX_DISPLAYED_RPM)
		var spin_degree  : int   = MAX_NEEDLE_DEGREE - MIN_NEEDLE_DEGREE
		var needle_ratio : float = float(spin_degree) * rpm_ratio
		_rpm_needle.rect_rotation = MIN_NEEDLE_DEGREE + needle_ratio

# - DisplayedVehicle property -
func set_debug_vehicle(object : Vehicle) -> void:
	_displayed_vehicle = object
	# Set MaxRPM range
	var vehicle_max_rpm : float = float(_displayed_vehicle.MaxEngineRPM)
	var max_rpm_ratio   : float = (vehicle_max_rpm / float(MAX_DISPLAYED_RPM))
	var rpm_range_val   : int   = int(abs(1 - max_rpm_ratio) * 100) + 10
	_rpm_range.value = rpm_range_val

func get_debug_vehicle() -> Vehicle:
	return _displayed_vehicle
