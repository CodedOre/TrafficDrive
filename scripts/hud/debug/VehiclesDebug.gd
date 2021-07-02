# Copyright 2021, Frederick Schenk

# --- VehicleDebug Script ---
# A script to manage the debug screen for a Vehicle.

extends GridContainer

# -- Properties --

var DebuggedVehicle : Vehicle setget set_debug_vehicle, get_debug_vehicle

# -- Variables --

var _valid_vehicle : bool = false
var _debug_vehicle : Vehicle

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	_show_or_hide()

# - Set's a debugged vehicle after a check -
func set_debug_vehicle(node : Vehicle) -> void:
	_valid_vehicle = false
	_debug_vehicle = null
	if node != null:
		if node is Vehicle:
			_debug_vehicle = node
			_valid_vehicle = true
	_update_static_labels()
	_show_or_hide()

func get_debug_vehicle() -> Vehicle:
	return _debug_vehicle

# - Hide or Show the HUD -
func _show_or_hide() -> void:
	$SpeedLabel.visible       = _valid_vehicle
	$SpeedValue.visible       = _valid_vehicle
	$GearLabel.visible        = _valid_vehicle
	$GearValue.visible        = _valid_vehicle
	$RPMLabel.visible         = _valid_vehicle
	$RPMValue.visible         = _valid_vehicle
	$XInputLabel.visible      = _valid_vehicle
	$XInputValue.visible      = _valid_vehicle
	$BInputLabel.visible      = _valid_vehicle
	$BInputValue.visible      = _valid_vehicle
	$YInputLabel.visible      = _valid_vehicle
	$YInputValue.visible      = _valid_vehicle
	$EngineLabel.visible      = _valid_vehicle
	$EngineValue.visible      = _valid_vehicle
	$BrakeLabel.visible       = _valid_vehicle
	$BrakeValue.visible       = _valid_vehicle
	$SteeringDegLabel.visible = _valid_vehicle
	$SteeringDegValue.visible = _valid_vehicle
	$SteeringRadLabel.visible = _valid_vehicle
	$SteeringRadValue.visible = _valid_vehicle

# - Updates static labels after a set vehicle -
func _update_static_labels() -> void:
	$VehicleValue.text = str(_debug_vehicle.get_name())

# - Processes interactive changes on runtime -
func _process(_delta : float) -> void:
	if _valid_vehicle:
		$SpeedValue.text       = str(_debug_vehicle.current_speed) + " km/h"
		$GearValue.text        = str(_debug_vehicle.VehicleData.GearsIdentifier[_debug_vehicle._current_gear])
		$RPMValue.text         = str(_debug_vehicle._engine_rpm)
		$XInputValue.text      = str(_debug_vehicle._input_engine)
		$BInputValue.text      = str(_debug_vehicle._input_brake)
		$YInputValue.text      = str(_debug_vehicle._input_steer)
		$EngineValue.text      = str(_debug_vehicle.engine_force)
		$BrakeValue.text       = str(_debug_vehicle.brake)
		$SteeringDegValue.text = str(_debug_vehicle._steer_angle)
		$SteeringRadValue.text = str(_debug_vehicle.steering)
