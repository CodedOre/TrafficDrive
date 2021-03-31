# Copyright 2021, Frederick Schenk

# --- VehicleLightsDebug Script ---
# A script to manage the debug screen for the VehicleLightsManager.

extends GridContainer

# -- Properties --

var DebuggedVehicle : Vehicle setget set_debug_vehicle, get_debug_vehicle

# -- Variables --

var _valid_vehicle : bool = false
var _debug_vehicle : Vehicle
var _debug_manager : VehicleLightsManager
var _mode_select   : int = -1
var _mode_labels   : PoolStringArray = ["", "", "", "", ""]
var _node_labels   : PoolStringArray = ["", "", "", "", ""]
var _node_values   : PoolStringArray = ["", "", "", "", ""]

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	_show_or_hide()
	$LightModeTimer.connect("timeout", self, "_cycle_modes")

# - Set's a debugged vehicle after a check -
func set_debug_vehicle(node : Vehicle) -> void:
	_valid_vehicle = false
	_debug_vehicle = null
	_debug_manager = null
	if node != null:
		var manager = node.get("_light_manager")
		if manager != null && manager is VehicleLightsManager:
			_debug_vehicle = node
			_debug_manager = manager
			_valid_vehicle = true
	_update_static_labels()
	_show_or_hide()

func get_debug_vehicle() -> Vehicle:
	return _debug_vehicle

# - Hide or Show the HUD -
func _show_or_hide() -> void:
	if _valid_vehicle:
		$ManagerValue.text = "active"
		$LightModeTimer.start()
		_cycle_modes()
	else:
		$ManagerValue.text = "inactive"
		$LightModeTimer.stop()
		_mode_select = -1
	$LightSumLabel.visible = _valid_vehicle
	$LightSumValue.visible = _valid_vehicle

# - Updates static labels after a set vehicle -
func _update_static_labels() -> void:
	$LightSumValue.text = str(_debug_vehicle.Lights.size())
	
	# Create cache for LightMode and ModeLights
	_mode_labels[0] = "NightLights:"
	_node_labels[0] = "Nodes:"
	for node in _debug_manager.frontlight_nodes:
		_node_labels[0] += "\n"
		_node_values[0]  += str(node.get_name()) + "\n"
	for node in _debug_manager.rearlight_nodes:
		if node.RearLight:
			_node_labels[0] += "\n"
			_node_values[0]  += str(node.get_name()) + "\n"
	
	_mode_labels[1] = "BrakeLights:"
	_node_labels[1] = "Nodes:"
	for node in _debug_manager.rearlight_nodes:
		if node.BrakeLight:
			_node_labels[1] += "\n"
			_node_values[1]  += str(node.get_name()) + "\n"
	
	_mode_labels[2] = "ReverseLights:"
	_node_labels[2] = "Nodes:"
	for node in _debug_manager.reverse_nodes:
		_node_labels[2] += "\n"
		_node_values[2]  += str(node.get_name()) + "\n"
	
	_mode_labels[3] = "TurnLeftLights:"
	_node_labels[3] = "Nodes:"
	for node in _debug_manager.turnleft_nodes:
		_node_labels[3] += "\n"
		_node_values[3]  += str(node.get_name()) + "\n"
	
	_mode_labels[4] = "TurnRightLights:"
	_node_labels[4] = "Nodes:"
	for node in _debug_manager.turnright_nodes:
		_node_labels[4] += "\n"
		_node_values[4]  += str(node.get_name()) + "\n"

# - Updates LightModes select when the timer changes -
func _cycle_modes() -> void:
	_mode_select = (_mode_select + 1) % 5
	$LightModeLabel.text  = _mode_labels[_mode_select]
	$ModeLightsLabel.text = _node_labels[_mode_select]
	$ModeLightsValue.text = _node_values[_mode_select]

# - Processes interactive changes on runtime -
func _process(_delta : float) -> void:
	if _valid_vehicle:
		match _mode_select:
			0:
				match _debug_manager.NightLights:
					VehicleLightsManager.NightLightMode.OFF:
						$LightModeValue.text = "inactive"
					VehicleLightsManager.NightLightMode.ON:
						$LightModeValue.text = "active"
					VehicleLightsManager.NightLightMode.FAR:
						$LightModeValue.text = "active (far)"
			1:
				if _debug_manager.BrakeLights:
					$LightModeValue.text = "active"
				else:
					$LightModeValue.text = "inactive"
			2:
				if _debug_manager.ReverseLights:
					$LightModeValue.text = "active"
				else:
					$LightModeValue.text = "inactive"
			3:
				if _debug_manager.TurnLeftLights:
					$LightModeValue.text = "active"
				else:
					$LightModeValue.text = "inactive"
			4:
				if _debug_manager.TurnRightLights:
					$LightModeValue.text = "active"
				else:
					$LightModeValue.text = "inactive"
