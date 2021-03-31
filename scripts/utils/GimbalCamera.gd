# Copyright 2021, Frederick Schenk

# --- GimbalCamera Script ---
# A script for a camera on a gimbal for use with the cars.

extends Spatial

# -- Enums --

# - States for the camera -
enum CameraState {NOSET, FREE, RESET, BEHIND}

# -- Constants --

# - Speed the camera resets -
const MOVE_SPEED     : float = 4.0
const MOVE_THRESHOLD : float = 0.01

# -- Properties --

# - The point the camera is looking at -
export (NodePath) var CameraPoint setget set_camera_point, get_camera_point

# - Active camera indicator -
export (bool) var current = false setget set_current, is_current

# -- Variables

# - Internal nodes -
onready var _outer_gimbal : Spatial = $OuterGimbal
onready var _inner_gimbal : Spatial = $OuterGimbal/InnerGimbal
onready var _camera_node  : Camera  = $OuterGimbal/InnerGimbal/Camera
var _current_point        : CameraPoint

# - Variables set by GameSettings -
onready var _x_dir             : int   =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
onready var _y_dir             : int   =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
onready var _mouse_sensitivity : float = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")

# - Internal variables for positions -
var _original_outer_transform : Transform
var _original_inner_transform : Transform
var   _behind_outer_transform : Transform

# - States at runtime -
var _state = CameraState.NOSET # CameraState

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	GameSettings.connect("setting_changed", self, "_modify_settings")

# - Runs every frame -
func _process(delta : float) -> void:
	if _state != CameraState.NOSET:
		global_transform = _current_point.global_transform
		match _state:
			CameraState.RESET:
				_move_camera(delta, _original_outer_transform, _original_inner_transform)
			CameraState.BEHIND:
				_move_camera(delta, _behind_outer_transform, _original_inner_transform)

# - Moves the camera according to mouse input -
func _input(event) -> void:
	if is_current() and _state != CameraState.NOSET:
		if event is InputEventMouseMotion:
			_state = CameraState.FREE
			if event.relative.x != 0:
				_outer_gimbal.rotate_object_local(Vector3.UP, _y_dir * event.relative.x * _mouse_sensitivity)
			if event.relative.y != 0:
				_inner_gimbal.rotate_object_local(Vector3.RIGHT, _x_dir * event.relative.y * _mouse_sensitivity)

# - Move the Camera to a point -
func _move_camera(delta : float, outer_target : Transform, inner_target : Transform) -> void:
	# Check if Gimbals are reset
	var moving_done : int = 0
	if _transforms_close(_outer_gimbal.transform, outer_target, MOVE_THRESHOLD):
		moving_done += 1
	if _transforms_close(_inner_gimbal.transform, inner_target, MOVE_THRESHOLD):
		moving_done += 1
	if moving_done == 2:
		_state = CameraState.FREE
		return
	# Interpolate further reset
	_outer_gimbal.transform = _outer_gimbal.transform.interpolate_with(outer_target, MOVE_SPEED * delta)
	_inner_gimbal.transform = _inner_gimbal.transform.interpolate_with(inner_target, MOVE_SPEED * delta)

# - If a transform is near of another -
func _transforms_close(a: Transform, b: Transform, threshold: float) -> bool:
	return (
		(a.basis.x - b.basis.x).length() < threshold
		and (a.basis.y - b.basis.y).length() < threshold
		and (a.basis.z - b.basis.z).length() < threshold
	)

# - Change internal variables when settings were modified -
func _modify_settings() -> void:
	_x_dir             =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
	_y_dir             =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
	_mouse_sensitivity = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")

# - Resets the camera to original position -
func reset_camera() -> void:
	_state = CameraState.RESET

# - Camera looks behind -
func look_behind() -> void:
	_state = CameraState.BEHIND

# - CameraPoint property -
func set_camera_point(point : NodePath) -> void:
	print("Let's set a point!")
	_current_point = get_node(point)
	print("Current Point is " + str(_current_point))
#	if ! _current_point is CameraPoint:
#		_state = CameraState.NOSET
#		push_error("GimbalCamera: Non valid CameraPoint set!")
#		return
	# Move GimbalCamera to CameraPoint
	global_transform = _current_point.global_transform
	# Reset Gimbal
	_outer_gimbal.transform = Transform()
	_inner_gimbal.transform = Transform()
	_camera_node.transform  = Transform().rotated(Vector3.UP, PI/1)
	# Configure Gimbal according to CameraPoints properties
	_camera_node.transform.origin.z = -1 * _current_point.CameraDistance
	_inner_gimbal.rotation_degrees  = Vector3(_current_point.CameraAngle, 0, 0)
	# Storing current transforms as reset transforms
	_original_outer_transform = _outer_gimbal.transform
	_original_inner_transform = _inner_gimbal.transform
	# Create and store transform for behind view
	_behind_outer_transform = _original_outer_transform.rotated(Vector3.UP, PI/1)
	_state = CameraState.FREE

func get_camera_point() -> NodePath:
	return _current_point.get_path()

# - Active camera property -
func set_current(value : bool) -> void:
	if _state != CameraState.NOSET:
		_camera_node.set_current(value)
	else:
		push_error("CimbalCamera: Target not set!")

func make_current() -> void:
	if _state != CameraState.NOSET:
		_camera_node.make_current()
	else:
		push_error("CimbalCamera: Target not set!")

func is_current() -> bool:
	if _state != CameraState.NOSET:
		return _camera_node.is_current()
	else:
		push_error("CimbalCamera: Target not set!")
		return false
