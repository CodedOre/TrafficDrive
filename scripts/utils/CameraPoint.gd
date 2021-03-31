# Copyright 2021, Frederick Schenk

# --- CCameraPoint Script ---
# A script for a point which is used by CarCamera.

extends Position3D
class_name CameraPoint

# -- Properties --

# - Gimbal settings -
export (float) onready var CameraDistance
export (int)   onready var CameraAngle
