# Copyright 2021, Frederick Schenk

# --- VehicleLight Script ---
# A script to provide information about an light to VehicleLightManager.
# This is really just some exported variables.

extends Node
class_name VehicleLight

# -- Enums --

enum Side {NONE, LEFT, RIGHT}

# -- Properties --

# - The usecases for this light -
export (bool) var HeadLight
export (bool) var RearLight
export (bool) var BrakeLight
export (Side) var TurningSignal
export (bool) var ReverseLight

# -- Variables --

# - If light node should be shown -
var light_active setget setlight, getlight

# - The light node of this VehicleLight -
onready var light_node = $Light

# - Internal variables -
var _show_light = true

# -- Functions --

# - Run at startup -
func _ready():
	GameSettings.connect("setting_changed", self, "_modify_light")
	_modify_light()

# - Modifies light node according to setting -
func _modify_light():
	# Adapt to "VehicleLightNode" setting
	match GameSettings.get_setting("Performance", "VehicleLightNode"):
		GameSettings.VehicleLightNode.OFF:
			_show_light = false
		GameSettings.VehicleLightNode.SPOT:
			if HeadLight:
				_show_light = true
			else:
				_show_light = false
		GameSettings.VehicleLightNode.FULL:
			_show_light = true
	# Adapt to "VehicleLightShadows" setting
	if HeadLight:
		var show_shadows : bool
		if GameSettings.get_setting("Performance", "VehicleLightShadows"):
			show_shadows = true
		else:
			show_shadows = false
		light_node.shadow_enabled = show_shadows
	if ! _show_light:
		light_node.visible = _show_light

# - Setter and Getter for light visibility -
# Is affected by a performance setting
func setlight(value):
	if _show_light:
		light_node.set_visible(value)

func getlight():
	return _show_light
