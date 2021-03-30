# Copyright 2021, Frederick Schenk

# --- CarCamera Script ---
# A script for a camera which allows rotation around a car.

extends Spatial

# -- Properties --

# - Active camera indicator -
export (bool) var current = false setget set_current, is_current

# -- Variables

# - Internal nodes -
onready var _camera_node = $InnerGimbal/Camera
onready var _gimbal_node = $InnerGimbal

# - Internal variables -
onready var x_dir             =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
onready var y_dir             =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
onready var mouse_sensitivity = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")

# -- Functions --

# - Run at startup -
func _ready():
	GameSettings.connect("setting_changed", self, "_modify_settings")
	pass

# - Change internal variables when settings were modified -
func _modify_settings():
	x_dir             =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
	y_dir             =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
	mouse_sensitivity = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")

# - Moves the camera according to mouse input -
func _input(event):
	if is_current():
		if event is InputEventMouseMotion:
			if event.relative.x != 0:
				rotate_object_local(Vector3.UP, y_dir * event.relative.x * mouse_sensitivity)
			if event.relative.y != 0:
				_gimbal_node.rotate_object_local(Vector3.RIGHT, x_dir * event.relative.y * mouse_sensitivity)

# - Active camera property -
func set_current(value):
	_camera_node.set_current(value)

func make_current():
	_camera_node.make_current()

func is_current():
	return _camera_node.is_current()
