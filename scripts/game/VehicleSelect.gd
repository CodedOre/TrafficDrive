# Copyright 2021, Frederick Schenk

# --- VehicleSelect Script ---
# The script for selecting a vehicle.

extends Spatial

# -- Properties --

# - All vehicles to be selected -
export (Dictionary) var VehicleViews = Dictionary()

# -- Variables --

# - Internal nodes
var vehicle_pool : Array = Array()

# - HUD nodes -
onready var back_button : Button = $HUD/Selector/BackButton
onready var next_button : Button = $HUD/Selector/NextButton

# -- Functions --

# - Runs at startup -
func _ready():
	# Detect all vehicles and check for CameraPoint
	for vehicle in VehicleViews.keys():
		if ! vehicle is NodePath or ! VehicleViews[vehicle] is NodePath:
			push_error("VehicleSelect: VehicleViews contains non-NodePath!")
			return
		if ! get_node(vehicle) is Vehicle or ! get_node(VehicleViews[vehicle]) is Position3D:
			push_error("VehicleSelect: No valid format of VehicleViews (Correct would be [Vehicle : Position3D])")
			return
		var vehicle_node  : Vehicle    = get_node(vehicle)
		var viewport_node : Position3D = get_node(VehicleViews[vehicle])
