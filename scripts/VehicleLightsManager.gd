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
var frontlight_nodes = Array()
var  rearlight_nodes = Array()
var   turnleft_nodes = Array()
var  turnright_nodes = Array()
var    reverse_nodes = Array()

# -- Functions --

# - Startup function -
func _ready():
	for path in lights_paths:
		# Get node from path and verify it's an VehicleLight with attached Light
		var node = get_node(path)
		if node != VehicleLight:
			push_error("VehicleLightsManager: Processed node is not a VehicleLight!")
			break
		if node.light_node != null:
			push_error("VehicleLightsManager: Processed node doesn't contain a light node!")
			break
		# Check the set states and assign it to the right arrays
		# Also pushes an error if an light is in conflicting groups
		if node.HeadLight:
			# Headlights can only be Headlights
			if node.RearLight || ! node.TurningSignal.None || node.ReverseLight:
				push_error("VehicleLightsManager: Processed node has invalid configuration!")
				break
			frontlight_nodes.append(node)
			break
		if node.RearLight:
			# RearLights can't be Headlights or ReverseLights
			if node.HeadLight || node.ReverseLight:
				push_error("VehicleLightsManager: Processed node has invalid configuration!")
				break
			# If RearLight also works as TurningSignal, then append to the right group too
			if node.TurningSignal.Left:
				turnleft_nodes.append(node)
			if node.TurningSignal.Right:
				turnright_nodes.append(node)
			rearlight_nodes.append(node)
			break
		if ! node.TurningSignal.None:
			# TurningSignals can't be Headlights or ReverseLights
			if node.HeadLight || node.ReverseLight:
				push_error("VehicleLightsManager: Processed node has invalid configuration!")
				break
			if node.TurningSignal.Left:
				turnleft_nodes.append(node)
			if node.TurningSignal.Right:
				turnright_nodes.append(node)
			break
		if node.ReverseLight:
			# ReverseLights can't be Headlights or RearLights
			if node.HeadLight || node.RearLight:
				push_error("VehicleLightsManager: Processed node has invalid configuration!")
				break
			reverse_nodes.append(node)
			break

# - Set front lights -
