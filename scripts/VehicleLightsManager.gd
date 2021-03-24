# Copyright 2021, Frederick Schenk

# --- VehicleLightsManager Script ---
# A script to set the lighst on a vehicle to the correct states.

extends Node
class_name VehicleLightsManager

# -- Properties --
onready var lights_paths

# -- Variables --

# - All lights materials
# FrontLight
const material_front_on   = preload("res://assets/materials/VehicleLights/FrontLightOff.material")
const material_front_off  = preload("res://assets/materials/VehicleLights/FrontLightOn.material")
const material_front_high = preload("res://assets/materials/VehicleLights/FrontLightHighBeam.material")
# RearLights
const material_rear_off   = preload("res://assets/materials/VehicleLights/RearLightOff.material")
const material_rear_on    = preload("res://assets/materials/VehicleLights/RearLightOn.material")
const material_rear_brake = preload("res://assets/materials/VehicleLights/RearLightBrake.material")
# ReverseLights
const material_reverse_off = preload("res://assets/materials/VehicleLights/ReverseLightOff.material")
const material_reverse_on  = preload("res://assets/materials/VehicleLights/ReverseLightOn.material")
# TurningSignal
const material_turning_off = preload("res://assets/materials/VehicleLights/TurningSignalOff.material")
const material_turning_on  = preload("res://assets/materials/VehicleLights/TurningSignalOn.material")

# - All lights to manage -
var light_nodes = Array()

# -- Functions --
func _ready():
	for path in lights_paths:
		var node = get_node(path)
		if node != VehicleLight:
			push_error("VehicleLightsManager: Processed node is not a VehicleLight!")
			break
		if node.light_node != null:
			push_error("VehicleLightsManager: Processed node doesn't contain a light node!")
			break
		light_nodes.append(node)
