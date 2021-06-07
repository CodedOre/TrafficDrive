# Copyright 2021, Frederick Schenk

# --- VehicleInfo Script ---
# Shows information about the vehicle.

extends MarginContainer

# -- Properties --

var DisplayedVehicle : Vehicle setget set_debug_vehicle, get_debug_vehicle

# -- Variables --

# - Internal nodes -
onready var _speed_field : Label = $Background/SpeedValue
onready var _gear_field  : Label = $Background/GearValue

# - Runtime variables -
var _vehicle_connected : bool
var _displayed_vehicle : Vehicle

# -- Functions --

# - Runs at every frame -

func _physics_process(_delta):
	if _displayed_vehicle != null:
		_speed_field.text = str(_displayed_vehicle.current_speed)
		_gear_field.text  = _displayed_vehicle.GearsIdentifier[_displayed_vehicle._current_gear]

# - DisplayedVehicle -

func set_debug_vehicle(object : Vehicle) -> void:
	_displayed_vehicle = object

func get_debug_vehicle() -> Vehicle:
	return _displayed_vehicle
