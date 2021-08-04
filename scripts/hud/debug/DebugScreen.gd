# Copyright 2021, Frederick Schenk

# --- DebugScreen Script ---
# The central screen showing the debug informations.

extends VBoxContainer

# -- Properties --

var DebuggedVehicle : Vehicle setget set_debug_vehicle, get_debug_vehicle

# -- Variables --

# - Internal nodes -
onready var _graphics_debug : GridContainer = $GraphicsDebug
onready var _vehicles_debug : GridContainer = $VehiclesDebug
onready var _vehlight_debug : GridContainer = $VehicleLightsDebug

# - Runtime variables -
var _debugged_vehicle : Vehicle

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	# Connect GameSettings
	GameSettings.connect("setting_changed", self, "_modify_settings")
	visible = GameSettings.get_setting("Meta", "DisplayDebugInfos")

# - DebuggedVehicle property -
func set_debug_vehicle(node : Vehicle) -> void:
	_debugged_vehicle = node
	_vehicles_debug.set_debug_vehicle(_debugged_vehicle)
	_vehlight_debug.set_debug_vehicle(_debugged_vehicle)

func get_debug_vehicle() -> Vehicle:
	return _debugged_vehicle

# - Adapt to changed settings -
func _modify_settings() -> void:
	visible = GameSettings.get_setting("Meta", "DisplayDebugInfos")
