# Copyright 2021, Frederick Schenk

# --- GimbalCamera Script ---
# A script for a camera on a gimbal for use with the cars.

extends Spatial

# -- Enums --

# - States for the camera -
enum CameraState {NOSET, FREE, MOUSE, RESET, BEHIND}

# -- Constants --

# - Speed the camera resets -
const MOVE_SPEED     : float = 4.0
const MOVE_THRESHOLD : float = 0.02

# -- Properties --

# - A path to a CameraPoint -
export (NodePath) var CameraPointPath setget set_camera_point_path, get_camera_point_path
export (NodePath) var VehiclePath     setget set_vehicle_path, get_vehicle_path

# - Active camera indicator -
export (bool) var current = false setget set_current, is_current

# -- Variables

# - The point the camera is centered around -
var camera_point : CameraPoint setget set_camera_point, get_camera_point
var vehicle      : Vehicle     setget set_vehicle, get_vehicle

# - Internal nodes -
onready var _outer_gimbal : Spatial = $OuterGimbal
onready var _inner_gimbal : Spatial = $OuterGimbal/InnerGimbal
onready var _camera_node  : Camera  = $OuterGimbal/InnerGimbal/Camera

# - Variables set by GameSettings -
onready var _x_dir             : int   =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
onready var _y_dir             : int   =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
onready var _mouse_sensitivity : float = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")

# - Internal variables for positions -
var _original_outer_transform : Transform
var _original_inner_transform : Transform
var   _behind_outer_transform : Transform

# - States at runtime -
var _state               = CameraState.NOSET # CameraState
var _mouse_delta : float = 0.0

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	GameSettings.connect("setting_changed", self, "_modify_settings")

# - Runs every frame -
func _process(delta : float) -> void:
	if _state != CameraState.NOSET:
		if ! _transforms_close(global_transform, camera_point.global_transform, MOVE_THRESHOLD):
			_follow_point(delta)
		if _state == CameraState.MOUSE:
			_mouse_delta += delta
			if _mouse_delta > 1:
				_state = CameraState.FREE
		else:
			if camera_point.state_request == CameraPoint.RequestState.RESET:
				_state = CameraState.RESET
			if camera_point.state_request == CameraPoint.RequestState.BEHIND:
				_state = CameraState.BEHIND
		match _state:
			CameraState.RESET:
				_move_camera(delta, _original_outer_transform, _original_inner_transform)
			CameraState.BEHIND:
				_move_camera(delta, _behind_outer_transform, _original_inner_transform)

# - Moves the camera according to mouse input -
func _input(event) -> void:
	if is_current() and _state != CameraState.NOSET:
		if event is InputEventMouseMotion:
			_mouse_delta = 0.0
			_state = CameraState.MOUSE
			if event.relative.x != 0:
				_outer_gimbal.rotate_object_local(Vector3.UP, _y_dir * event.relative.x * _mouse_sensitivity)
			if event.relative.y != 0:
				_inner_gimbal.rotate_object_local(Vector3.RIGHT, _x_dir * event.relative.y * _mouse_sensitivity)
			_inner_gimbal.rotation.x = clamp(_inner_gimbal.rotation.x, 0.01, 1.14)

func _follow_point(delta : float) -> void:
	var self_transform  : Transform = Transform(global_transform.basis, camera_point.global_transform.origin)
	var point_transform : Transform = _nonrot_transform(camera_point)
	match camera_point.CameraTurn:
		CameraPoint.TurnVariant.NONE:
			global_transform = point_transform
		CameraPoint.TurnVariant.NORMAL:
			global_transform = self_transform.interpolate_with(point_transform, MOVE_SPEED * delta)
		CameraPoint.TurnVariant.INVERT:
			global_transform = point_transform
	if ! camera_point.FixedPosition:
		var camera_transform : Transform = _camera_node.transform
		camera_transform.origin.z = dectime(-1 * camera_point.CameraDistance, abs(camera_point.point_speed), -0.01)
		_camera_node.transform = _camera_node.transform.interpolate_with(camera_transform, MOVE_SPEED * delta)

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
func _transforms_close(a : Transform, b : Transform, threshold : float) -> bool:
	return (
		(a.basis.x - b.basis.x).length() < threshold
		and (a.basis.y - b.basis.y).length() < threshold
		and (a.basis.z - b.basis.z).length() < threshold
		and (a.origin  - b.origin).length()  < threshold
	)

# - Returns a Transform tha is at a Node's position, but only y rotation -
func _nonrot_transform(base : Spatial) -> Transform:
	var position : Vector3 = base.global_transform.origin
	var y_rotate : float   = base.global_transform.basis.get_euler().y
	return Transform(Basis(Vector3.UP, y_rotate), position)

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

# - CameraPoint path property -
func set_camera_point_path(path : NodePath) -> void:
	set_camera_point(get_node(path))

func get_camera_point_path() -> NodePath:
	return camera_point.get_path()

# - CameraPoint variable -
func set_camera_point(point : CameraPoint) -> void:
	if point == null:
		push_error("GimbalCamera: No valid CameraPoint given!")
		return
	camera_point = point
	# Move GimbalCamera to CameraPoint
	global_transform = _nonrot_transform(camera_point)
	# Reset Gimbal
	_outer_gimbal.transform = Transform()
	_inner_gimbal.transform = Transform()
	_camera_node.transform  = Transform().rotated(Vector3.UP, PI/1)
	# Configure Gimbal according to CameraPoints properties
	_camera_node.transform.origin.z = -1 * camera_point.CameraDistance
	_inner_gimbal.rotation_degrees  = Vector3(camera_point.CameraAngle, 0, 0)
	# Storing current transforms as reset transforms
	_original_outer_transform = _outer_gimbal.transform
	_original_inner_transform = _inner_gimbal.transform
	# Create and store transform for behind view
	_behind_outer_transform = _original_outer_transform.rotated(Vector3.UP, PI)
	_state = CameraState.FREE

func get_camera_point() -> CameraPoint:
	return camera_point

# - Vehicle path property -
func set_vehicle_path(path: NodePath) -> void:
	set_vehicle(get_node(path))

func get_vehicle_path() -> NodePath:
	return vehicle.get_path()

# - Vehicle variable -
func set_vehicle(node : Vehicle) -> void:
	if vehicle != null:
		if vehicle.is_connected("camera_changed", self, "change_point"):
			vehicle.disconnect("camera_changed", self, "change_point")
	vehicle = node
	set_camera_point(vehicle._camera_point)
	vehicle.connect("camera_changed", self, "change_point")

func get_vehicle() -> Vehicle:
	return vehicle

# - Updates the camera point -
func change_point() -> void:
	set_camera_point(vehicle._camera_point)

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
