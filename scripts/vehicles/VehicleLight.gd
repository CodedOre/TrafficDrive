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
	# Set lights according to "VehicleLight" setting
	var show_front_shadows : bool = false
	match GameSettings.get_setting("Graphics", "VehicleLight"):
		GameSettings.VehicleLight.HIGH:
			show_front_shadows = true
			_show_light = true
		GameSettings.VehicleLight.MEDIUM:
			show_front_shadows = false
			_show_light = true
		GameSettings.VehicleLight.LIGHT:
			show_front_shadows = false
			if FrontLight and FrontMode.MAIN:
				_show_light = true
			else:
				_show_light = false
	if FrontLight and FrontMode.MAIN:
		light_node.shadow_enabled = show_front_shadows
	if ! _show_light:
		light_node.visible = _show_light

# - Setter and Getter for light visibility -
# Is affected by a performance setting
func setlight(value) -> void:
	if _show_light:
		light_node.set_visible(value)

func getlight() -> bool:
	return _show_light
