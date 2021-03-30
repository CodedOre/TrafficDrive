# Copyright 2021, Frederick Schenk

# --- CarCamera Script ---
# A script for a camera which allows rotation around a car.

extends Spatial

# -- Enums --

# - States for the camera -
enum CameraState {FREE, RESET, BEHIND}

# -- Constants --

# - Speed the camera resets -
const RESET_SPEED     : float = 4.0
const RESET_THRESHOLD : float = 0.01

# -- Properties --

# - Camera position -
export (float) onready var CameraDistance
export (int)   onready var CameraAngle

# - Active camera indicator -
export (bool) var current = false setget set_current, is_current

# -- Variables

# - Internal nodes -
onready var _camera_node : Camera  = $InnerGimbal/Camera
onready var _gimbal_node : Spatial = $InnerGimbal

# - Variables set by GameSettings -
onready var _x_dir             : int   =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
onready var _y_dir             : int   =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
onready var _mouse_sensitivity : float = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")

# - Internal variables for positions -
var _original_outer_transform : Transform
var _original_inner_transform : Transform
var   _behind_outer_transform : Transform

# - States at runtime -
var _state # CameraState

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	# warning-ignore:return_value_discarded
	GameSettings.connect("setting_changed", self, "_modify_settings")
	# CameraDistance and CameraAngle are once set at start
	_camera_node.transform.origin.z = -1 * CameraDistance
	_gimbal_node.rotation_degrees = Vector3(CameraAngle, 0, 0)
	# Storing current transforms as reset transforms
	_original_outer_transform = transform
	_original_inner_transform = _gimbal_node.transform
	# Create and store transform for behind view
	_behind_outer_transform = _original_outer_transform.rotated(Vector3.UP, PI/1)

# - Runs every frame -
func _process(delta : float) -> void:
	match _state:
		CameraState.RESET:
			_move_camera(delta, _original_outer_transform, _original_inner_transform)
		CameraState.BEHIND:
			_move_camera(delta, _behind_outer_transform, _original_inner_transform)

# - Change internal variables when settings were modified -
func _modify_settings() -> void:
	_x_dir             =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
	_y_dir             =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
	_mouse_sensitivity = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")

# - Moves the camera according to mouse input -
func _input(event) -> void:
	if is_current():
		if event is InputEventMouseMotion:
			_state = CameraState.FREE
			if event.relative.x != 0:
				rotate_object_local(Vector3.UP, _y_dir * event.relative.x * _mouse_sensitivity)
			if event.relative.y != 0:
				_gimbal_node.rotate_object_local(Vector3.RIGHT, _x_dir * event.relative.y * _mouse_sensitivity)

# - Resets the camera to original position -
func reset_camera() -> void:
	_state = CameraState.RESET

# - Camera looks behind -
func look_behind() -> void:
	_state = CameraState.BEHIND

# - Move the Camera to a point -
func _move_camera(delta : float, outer_target : Transform, inner_target : Transform) -> void:
	# Check if Gimbals are reset
	var moving_done : int = 0
	if _close_transforms(transform, outer_target, RESET_THRESHOLD):
		moving_done += 1
	if _close_transforms(_gimbal_node.transform, inner_target, RESET_THRESHOLD):
		moving_done += 1
	if moving_done == 2:
		_state = CameraState.FREE
		return
	# Interpolate further reset
	transform = transform.interpolate_with(outer_target, RESET_SPEED * delta)
	_gimbal_node.transform = _gimbal_node.transform.interpolate_with(inner_target, RESET_SPEED * delta)

# - If a transform is near of another -
func _close_transforms(a: Transform, b: Transform, threshold: float) -> bool:
	return (
		(a.basis.x - b.basis.x).length() < threshold
		and (a.basis.y - b.basis.y).length() < threshold
		and (a.basis.z - b.basis.z).length() < threshold
	)

# - Active camera property -
func set_current(value : bool) -> void:
	_camera_node.set_current(value)

func make_current() -> void:
	_camera_node.make_current()

func is_current() -> bool:
	return _camera_node.is_current()
