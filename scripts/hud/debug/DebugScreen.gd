# Copyright 2021, Frederick Schenk

# --- DebugScreen Script ---
# The central screen showing the debug informations.

extends VBoxContainer

# -- Properties --

var DebuggedVehicle : Vehicle setget set_debug_vehicle, get_debug_vehicle

# -- Variables --

# - Internal nodes -
onready var _graphics_debug : GridContainer = $GraphicsDebug
onready var _vehlight_debug : GridContainer = $VehicleLightsDebug

# - Runtime variables -
var _debugged_vehicle : Vehicle

# -- Functions --

# - DebuggedVehicle property -
func set_debug_vehicle(node : Vehicle) -> void:
	_debugged_vehicle = node
	_vehlight_debug.set_debug_vehicle(_debugged_vehicle)

func get_debug_vehicle() -> Vehicle:
	return _debugged_vehicle
