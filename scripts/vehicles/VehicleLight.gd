# Copyright 2021, Frederick Schenk

# --- VehicleLight Script ---
# A script to provide information about an light to VehicleLightManager.
# This is really just some exported variables.

extends Node
class_name VehicleLight

# -- Enums --

enum Side      {NONE, LEFT, RIGHT}
enum FrontMode {NONE, ASSIST, MAIN}

# -- Properties --

# - The usecases for this light -
export (FrontMode) var FrontLight
export (bool)      var RearLight
export (bool)      var BrakeLight
export (Side)      var TurningSignal
export (bool)      var ReverseLight

# -- Variables --

# - If light node should be shown -
var light_active : bool setget setlight, getlight

# - The light node of this VehicleLight -
onready var light_node : Light = $Light

# - Internal variables -
var _show_light : bool = true

# -- Functions --

# - Run at startup -
func _ready() -> void:
	GameSettings.connect("setting_changed", self, "_modify_light")
	_modify_light()

# - Modifies light node according to setting -
func _modify_light() -> void:
	# Adapt to "VehicleLightNode" setting
	match GameSettings.get_setting("Performance", "VehicleLightNode"):
		GameSettings.VehicleLightNode.OFF:
			_show_light = false
		GameSettings.VehicleLightNode.SPOT:
			if FrontLight and FrontMode.MAIN:
				_show_light = true
			else:
				_show_light = false
		GameSettings.VehicleLightNode.FULL:
			_show_light = true
	# Adapt to "VehicleLightShadows" setting
	if FrontLight and FrontMode.MAIN:
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
func setlight(value) -> void:
	if _show_light:
		light_node.set_visible(value)

func getlight() -> bool:
	return _show_light
