# Copyright 2021, Frederick Schenk

# --- CCameraPoint Script ---
# A script for a point which is used by CarCamera.

extends Position3D
class_name CameraPoint

# -- Enums --

# - Request state -
enum RequestState {NONE, RESET, BEHIND}

# -- Properties --

# - Gimbal settings -
export (float) onready var CameraDistance
export (int)   onready var CameraAngle

# -- Variables --

# - Request state property -
var state_request # RequestState

# - Current movement of point -
var point_speed : int
var point_steer : float
