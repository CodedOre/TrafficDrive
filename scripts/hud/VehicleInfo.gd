# Copyright 2021, Frederick Schenk

# --- VehicleInfo Script ---
# Shows information about the vehicle.

extends Control

# -- Constants --

# - LightsIcons textures -
const TURN_LEFT_OFF_TEXTURE  : Texture = preload("res://assets/textures/VehicleInfo/TurnLeftSignalOff.png")
const TURN_LEFT_ON_TEXTURE   : Texture = preload("res://assets/textures/VehicleInfo/TurnLeftSignalOn.png")
const TURN_RIGHT_OFF_TEXTURE : Texture = preload("res://assets/textures/VehicleInfo/TurnRightSignalOff.png")
const TURN_RIGHT_ON_TEXTURE  : Texture = preload("res://assets/textures/VehicleInfo/TurnRightSignalOn.png")
const NIGHTLIGHT_OFF_TEXTURE : Texture = preload("res://assets/textures/VehicleInfo/NightLightsOff.png")
const NIGHTLIGHT_ONE_TEXTURE : Texture = preload("res://assets/textures/VehicleInfo/NightLightsOne.png")
const NIGHTLIGHT_TWO_TEXTURE : Texture = preload("res://assets/textures/VehicleInfo/NightLightsTwo.png")

# - RPM Range constant -
const MAX_DISPLAYED_RPM : int = 8000

# - Needle contants -
const MIN_NEEDLE_DEGREE : int = -125
const MAX_NEEDLE_DEGREE : int =  125

# -- Properties --

var DisplayedVehicle : Vehicle setget set_displayed_vehicle, get_displayed_vehicle

# -- Variables --

# - Internal nodes -
onready var _speed_field     : Label           = $Background/SpeedValue
onready var _gear_field      : Label           = $Background/GearValue
onready var _rpm_range       : TextureProgress = $RPMRange
onready var _rpm_needle      : TextureRect     = $Needle
onready var _turn_left_icon  : TextureRect     = $LightsIcons/TurnLeftSymbol
onready var _turn_right_icon : TextureRect     = $LightsIcons/TurnRightSymbol
onready var _nightlight_icon : TextureRect     = $LightsIcons/Nightlightsymbol

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
		
		# Update LightsIcons
		if _displayed_vehicle._light_manager != null:
			match _displayed_vehicle._light_manager.NightLights:
				VehicleLightsManager.NightLightMode.OFF:
					_nightlight_icon.texture = NIGHTLIGHT_OFF_TEXTURE
				VehicleLightsManager.NightLightMode.ON:
					_nightlight_icon.texture = NIGHTLIGHT_ONE_TEXTURE
				VehicleLightsManager.NightLightMode.FAR:
					_nightlight_icon.texture = NIGHTLIGHT_TWO_TEXTURE
			
			if _displayed_vehicle._light_manager._turnleft_state:
				_turn_left_icon.texture = TURN_LEFT_ON_TEXTURE
			else:
				_turn_left_icon.texture = TURN_LEFT_OFF_TEXTURE
			if _displayed_vehicle._light_manager._turnright_state:
				_turn_right_icon.texture = TURN_RIGHT_ON_TEXTURE
			else:
				_turn_right_icon.texture = TURN_RIGHT_OFF_TEXTURE

# - DisplayedVehicle property -
func set_displayed_vehicle(object : Vehicle) -> void:
	_displayed_vehicle = object
	# Set MaxRPM range
	var vehicle_max_rpm : float = float(_displayed_vehicle.MaxEngineRPM)
	var max_rpm_ratio   : float = (vehicle_max_rpm / float(MAX_DISPLAYED_RPM))
	var rpm_range_val   : int   = int(abs(1 - max_rpm_ratio) * 100) + 10
	_rpm_range.value = rpm_range_val

func get_displayed_vehicle() -> Vehicle:
	return _displayed_vehicle
