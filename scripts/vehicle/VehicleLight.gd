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
export (Side) var TurningSignal
export (bool) var ReverseLight

# -- Variables --

onready var light_node = $Light
