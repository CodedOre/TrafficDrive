# Copyright 2021, Frederick Schenk

# --- VehicleLightsDebug Script ---
# A script to manage the debug screen for the VehicleLightsManager.

extends GridContainer

# -- Properties --

var DebuggedVehicle setget set_debug_vehicle, get_debug_vehicle

# -- Variables --

var _valid_vehicle : bool = false
var _debug_vehicle : Node
var _debug_manager : VehicleLightsManager

# -- Functions --

# - Runs at startup -
func _ready():
	_show_or_hide()

# - Runs at every frame -
func _process(_delta):
	if _valid_vehicle:
		pass

# - Set's a debugged vehicle after a check -
func set_debug_vehicle(value):
	print("HELP!")
	_valid_vehicle = false
	_debug_vehicle = null
	_debug_manager = null
	if value != null:
		var manager = value.get("light_managment")
		if manager != null && manager is VehicleLightsManager:
			_debug_vehicle = value
			_debug_manager = manager
			_valid_vehicle = true
	_show_or_hide()
	_update_static_labels()

func get_debug_vehicle():
	return _debug_vehicle

# - Hide or Show the HUD -
func _show_or_hide():
	if _valid_vehicle:
		$ManagerValue.text = "active"
	else:
		$ManagerValue.text = "inactive"
	$LightSumLabel.visible = _valid_vehicle
	$LightSumValue.visible = _valid_vehicle

# - Updates static labels after a set vehicle -
func _update_static_labels():
	$LightSumValue.text = str(_debug_vehicle.all_light_nodes.size())
