# Copyright 2021, Frederick Schenk

# --- VehicleLightsManager Script ---
# A script to set the lighst on a vehicle to the correct states.

extends Node
class_name VehicleLightsManager

# -- Enums --

enum NightLightMode {OFF, ON, FAR}

# -- Properties --

# - Light Settings -
const HeadLightRange     =  30
const HeadLightEnergy    =   4
const HighBeamRange      =  60
const HighBeamEnergy     =   8
const RearLightEnergy    =   2
const BrakeLightEnergy   =   4
const TurnSignalInterval = .75

# - Light States -
var     NightLights        setget set_nightlights,     get_nightlights
var     BrakeLights : bool setget set_brakelights,     get_brakelights
var   ReverseLights : bool setget set_reverselights,   get_reverselights
var  TurnLeftLights : bool setget set_turnleftlights,  get_turnleftlights
var TurnRightLights : bool setget set_turnrightlights, get_turnrightlights

# -- Variables --

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
var _brake_state
var _reverse_state
var _turnleft_state
var _turnright_state

# - Internal variables for state calculation
var _turning_timer = Timer.new()
var _turning_state
var _turning_left
var _turning_right

# -- Functions --

# - Init the class -
func _init(parent, all_lights):
	# Launch init functions
	process_nodes(all_lights)
	preset_lights(parent)

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
func preset_lights(parent):
	set_nightlights(NightLightMode.OFF)
	set_brakelights(false)
	set_reverselights(false)
	set_turnleftlights(false)
	set_turnrightlights(false)
	_turning_timer.wait_time = TurnSignalInterval
	_turning_timer.connect("timeout", self, "set_turn_signals")
	parent.add_child(_turning_timer)

# - Set night lights -
func set_nightlights(mode):
	_night_state = mode
	set_lights()

func get_nightlights():
	return _night_state

# - Set brake lights -
func set_brakelights(value):
	_brake_state = value
	set_lights()

func get_brakelights():
	return _brake_state

# - Set reverse lights -
func set_reverselights(value):
	_reverse_state = value
	set_lights()

func get_reverselights():
	return _reverse_state

# - Set turn signals -
func set_turnleftlights(value):
	_turning_left = value
	set_turn_timer()

func set_turnrightlights(value):
	_turning_right = value
	set_turn_timer()

func get_turnleftlights():
	return _turning_left

func get_turnrightlights():
	return _turning_right

func set_turn_timer():
	# If no turn signal is on, stop the timer
	if ! _turning_left && ! _turning_right:
		_turning_timer.stop()
		set_turn_signals()
	# Start timer if not running
	elif _turning_timer.is_stopped():
		_turning_timer.start()
		_turning_state = true
		set_turn_signals()

func set_turn_signals():
	# Called by the timer, automatically cycles the light states
	_turning_state = ! _turning_state
	if _turning_left:
		_turnleft_state = ! _turning_state
	else:
		_turnleft_state = false
	if _turning_right:
		_turnright_state = ! _turning_state
	else:
		_turnright_state = false
	set_lights()

# - Sets all lights according to it's states
func set_lights():
	# Set FrontLights
	for node in frontlight_nodes:
		match _night_state:
			NightLightMode.OFF:
				# Disables the light and set the material to "off"
				node.material_override  = material_front_off
				node.light_active       = false
			NightLightMode.ON:
				# Sets the light range and energy and the material to "on"
				node.material_override       = material_front_on
				node.light_node.spot_range   = HeadLightRange
				node.light_node.light_energy = HeadLightEnergy
				node.light_active            = true
			NightLightMode.FAR:
				# Sets the light range and energy and the material to "highbeam"
				node.material_override       = material_front_high
				node.light_node.spot_range   = HighBeamRange
				node.light_node.light_energy = HighBeamEnergy
				node.light_active            = true
	# Set RearLights
	for node in rearlight_nodes:
		# Check if lights performs turn signal duties as well
		if node.TurningSignal == VehicleLight.Side.LEFT:
			if _turning_left:
				# Wenn turn signal is active, override brake states
				if _turnleft_state:
					# Sets the light energy and the material to "brake"
					node.material_override       = material_rear_brake
					node.light_node.light_energy = BrakeLightEnergy
					node.light_active            = true
				else:
					match _night_state:
						NightLightMode.OFF:
							# Disables the light and sets the material to "off"
							node.material_override  = material_rear_off
							node.light_active       = false
						NightLightMode.ON, NightLightMode.FAR:
							# Enables the light and sets the material to "on"
							node.material_override       = material_rear_on
							node.light_node.light_energy = RearLightEnergy
							node.light_active            = true
				continue
		if node.TurningSignal == VehicleLight.Side.RIGHT:
			if _turning_right:
				# Wenn turn signal is active, override brake states
				if _turnright_state:
					# Sets the light energy and the material to "brake"
					node.material_override       = material_rear_brake
					node.light_node.light_energy = BrakeLightEnergy
					node.light_active            = true
				else:
					match _night_state:
						NightLightMode.OFF:
							# Disables the light and sets the material to "off"
							node.material_override  = material_rear_off
							node.light_active       = false
						NightLightMode.ON, NightLightMode.FAR:
							# Enables the light and sets the material to "on"
							node.material_override       = material_rear_on
							node.light_node.light_energy = RearLightEnergy
							node.light_active            = true
				continue
		if _brake_state:
			# Sets the light energy and the material to "brake"
			node.material_override       = material_rear_brake
			node.light_node.light_energy = BrakeLightEnergy
			node.light_active            = true
		else:
			match _night_state:
				NightLightMode.OFF:
					# Disables the light and sets the material to "off"
					node.material_override  = material_rear_off
					node.light_active       = false
				NightLightMode.ON, NightLightMode.FAR:
					# Enables the light and sets the material to "on"
					node.material_override       = material_rear_on
					node.light_node.light_energy = RearLightEnergy
					node.light_active            = true
	# Set TurnSignals
	for node in turnleft_nodes:
		if ! node.RearLight:
			if _turnleft_state:
				# Enables the light and sets the material to "on"
				node.material_override  = material_turning_on
				node.light_active       = true
			else:
				# Disables the light and sets the material to "off"
				node.material_override  = material_turning_off
				node.light_active       = false
	for node in turnright_nodes:
		if ! node.RearLight:
			if _turnright_state:
				# Enables the light and sets the material to "on"
				node.material_override  = material_turning_on
				node.light_active       = true
			else:
				# Disables the light and sets the material to "off"
				node.material_override  = material_turning_off
				node.light_active       = false
	# Set ReverseLights
	for node in reverse_nodes:
		if _reverse_state:
			# Enables the light and sets the material to "on"
			node.material_override  = material_reverse_on
			node.light_active       = true
		else:
			# Disables the light and sets the material to "off"
			node.material_override  = material_reverse_off
			node.light_active       = false
