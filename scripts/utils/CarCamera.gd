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

# -- Functions --

# - Moves the camera according to mouse input -
func _input(event):
	if is_current():
		if event is InputEventMouseMotion:
			if event.relative.x != 0:
				rotate_object_local(Vector3.UP, -1 * event.relative.x * 0.002)
			if event.relative.y != 0:
				_gimbal_node.rotate_object_local(Vector3.RIGHT, 1 * event.relative.y * 0.002)

# - Active camera property -
func set_current(value):
	_camera_node.set_current(value)

func make_current():
	_camera_node.make_current()

func is_current():
	return _camera_node.is_current()
