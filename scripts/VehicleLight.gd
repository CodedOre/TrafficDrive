# Copyright 2021, Frederick Schenk

# --- VehicleLight Script ---
# A script to provide information about an light to VehicleLightManager.
# This is really just some exported variables.

extends Node
class_name VehicleLight

# -- Variables --
enum Side {NONE, LEFT, RIGHT}
onready var light_node = $Light

# -- Properties --
export (bool) var HeadLight
export (bool) var RearLight
export (Side) var TurningSignal
export (bool) var ReverseLight
