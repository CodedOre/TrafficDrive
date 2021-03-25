# Copyright 2021, Frederick Schenk

# --- VehicleLightsManager Script ---
# A script to set the lighst on a vehicle to the correct states.

extends Node
class_name VehicleLightsManager

# -- Enums --

enum NightLightMode {OFF, ON, FAR}

# -- Properties --

# - FrontLight Settings -
const HeadLightRange  = 30
const HeadLightEnergy = 4
const HighBeamRange   = 60
const HighBeamEnergy  = 8

# -- Variables --

var nightlights setget set_nightlights, get_nightlights

# - All lights materials
# FrontLight
const material_front_off   = preload("res://assets/materials/VehicleLights/FrontLightOff.material")
const material_front_on    = preload("res://assets/materials/VehicleLights/FrontLightOn.material")
const material_front_high  = preload("res://assets/materials/VehicleLights/FrontLightHighBeam.material")
# RearLights
const material_rear_off    = preload("res://assets/materials/VehicleLights/RearLightOff.material")
const material_rear_on     = preload("res://assets/materials/VehicleLights/RearLightOn.material")
const material_rear_brake  = preload("res://assets/materials/VehicleLights/RearLightBrake.material")
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

# - Internal light states -
var _night_state

# -- Functions --

# - Init the class -
func _init(all_lights):
	process_nodes(all_lights)
	preset_lights()

# - Places all nodes into the wanted arrays -
func process_nodes(all_lights):
	for node in all_lights:
		# Get node from path and verify it's an VehicleLight with attached Light
		if ! node is Node:
			push_error("VehicleLightsManager: Array does not contain nodes!")
			break
		if ! node is VehicleLight:
			push_error("VehicleLightsManager: Processed node is not a VehicleLight!")
			continue
		if node.light_node == null:
			push_error("VehicleLightsManager: Processed node doesn't contain a light node!")
			continue
		# Check the set states and assign it to the right arrays
		# Also pushes an error if an light is in conflicting groups
		if node.HeadLight:
			# Headlights can only be Headlights
			if node.RearLight || ! node.TurningSignal == node.Side.NONE || node.ReverseLight:
				push_error("VehicleLightsManager: Processed node has invalid configuration!")
				continue
			frontlight_nodes.append(node)
			continue
		if node.RearLight:
			# RearLights can't be Headlights or ReverseLights
			if node.HeadLight || node.ReverseLight:
				push_error("VehicleLightsManager: Processed node has invalid configuration!")
				continue
			# If RearLight also works as TurningSignal, then append to the right group too
			match node.TurningSignal:
				node.Side.LEFT:
					turnleft_nodes.append(node)
				node.Side.RIGHT:
					turnright_nodes.append(node)
			rearlight_nodes.append(node)
			continue
		if ! node.TurningSignal == node.Side.NONE:
			# TurningSignals can't be Headlights or ReverseLights
			if node.HeadLight || node.ReverseLight:
				push_error("VehicleLightsManager: Processed node has invalid configuration!")
				continue
			match node.TurningSignal:
				node.Side.LEFT:
					turnleft_nodes.append(node)
				node.Side.RIGHT:
					turnright_nodes.append(node)
			continue
		if node.ReverseLight:
			# ReverseLights can't be Headlights or RearLights
			if node.HeadLight || ! node.TurningSignal == node.Side.NONE || node.RearLight:
				push_error("VehicleLightsManager: Processed node has invalid configuration!")
				continue
			reverse_nodes.append(node)
			continue
		push_error("VehicleLightsManager: Processed node has invalid configuration!")

# - Initial settings for the lights -
func preset_lights():
	set_nightlights(NightLightMode.OFF)

# - Set front lights -
func set_nightlights(mode):
	_night_state = mode
	# Set FrontLights
	for node in frontlight_nodes:
		match mode:
			NightLightMode.OFF:
				# Disables the light and set the material to "off"
				node.material_override  = material_front_off
				node.light_node.visible = false
			NightLightMode.ON:
				# Sets the light range and energy and the material to "on"
				node.material_override       = material_front_on
				node.light_node.visible      = true
				node.light_node.spot_range   = HeadLightRange
				node.light_node.light_energy = HeadLightEnergy
			NightLightMode.FAR:
				# Sets the light range and energy and the material to "highbeam"
				node.material_override       = material_front_high
				node.light_node.visible      = true
				node.light_node.spot_range   = HighBeamRange
				node.light_node.light_energy = HighBeamEnergy
	# Set RearLights
	for node in rearlight_nodes:
		match mode:
			NightLightMode.OFF:
				# Disables the light and set the material to "off"
				node.material_override  = material_rear_off
				node.light_node.visible = false
			NightLightMode.ON, NightLightMode.FAR:
				# Enables the light and set the material to "on"
				node.material_override  = material_rear_on
				node.light_node.visible = false

func get_nightlights():
	return _night_state
