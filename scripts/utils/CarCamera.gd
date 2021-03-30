# Copyright 2021, Frederick Schenk

# --- CarCamera Script ---
# A script for a camera which allows rotation around a car.

extends Spatial

# -- Functions --

# - Moves the camera according to mouse input -
func _input(event):
	if $InnerGimbal/Camera.is_current():
		if event is InputEventMouseMotion:
			if event.relative.x != 0:
				rotate_object_local(Vector3.UP, -1 * event.relative.x * 0.002)
			if event.relative.y != 0:
				$InnerGimbal.rotate_object_local(Vector3.RIGHT, 1 * event.relative.y * 0.002)
