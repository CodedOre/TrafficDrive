# Copyright 2021, Frederick Schenk

# --- CarCamera Script ---
# A script for a camera which allows rotation around a car.

extends Spatial

# -- Properties --

# - Camera position -
export (float) var CameraDistance = 4.5
export (float) var CameraHeight   = 1
export (int)   var CameraAngle    = 15

# - Active camera indicator -
export (bool) var current = false setget set_current, is_current

# -- Variables

# - Internal nodes -
onready var _camera_node = $InnerGimbal/Camera
onready var _gimbal_node = $InnerGimbal

# - Internal variables -
onready var _x_dir             =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
onready var _y_dir             =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
onready var _mouse_sensitivity = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")
var _original_outer_transform : Transform
var _original_inner_transform : Transform

# -- Functions --

# - Run at startup -
func _ready():
	GameSettings.connect("setting_changed", self, "_modify_settings")
	_original_outer_transform = transform
	_original_inner_transform = _gimbal_node.transform

# - Change internal variables when settings were modified -
func _modify_settings():
	_x_dir             =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
	_y_dir             =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
	_mouse_sensitivity = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")

# - Moves the camera according to mouse input -
func _input(event):
	if is_current():
		if event is InputEventMouseMotion:
			if event.relative.x != 0:
				rotate_object_local(Vector3.UP, _y_dir * event.relative.x * _mouse_sensitivity)
			if event.relative.y != 0:
				_gimbal_node.rotate_object_local(Vector3.RIGHT, _x_dir * event.relative.y * _mouse_sensitivity)

# - Resets the camera to original position -
func reset_camera():
	transform = _original_outer_transform
	_gimbal_node.transform = _original_inner_transform

# - Active camera property -
func set_current(value):
	_camera_node.set_current(value)

func make_current():
	_camera_node.make_current()

func is_current():
	return _camera_node.is_current()
