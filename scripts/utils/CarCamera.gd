# Copyright 2021, Frederick Schenk

# --- CarCamera Script ---
# A script for a camera which allows rotation around a car.

extends Spatial

# -- Constants --

# - Speed the camera resets -
const RESET_SPEED     : float = 4.0
const RESET_THRESHOLD : float = 0.01

# -- Properties --

# - Camera position -
export (float) onready var CameraDistance = 0
export (int)   onready var CameraAngle    = 0

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
var _original_outer_transform  : Transform
var _original_inner_transform  : Transform

# - States at runtime -
var _resetting_camera : bool = false

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	GameSettings.connect("setting_changed", self, "_modify_settings")
	# CameraDistance and CameraAngle are once set at start
	_camera_node.transform.origin.z = -1 * CameraDistance
	_gimbal_node.rotation_degrees = Vector3(CameraAngle, 0, 0)
	# Storing current transforms as reset transforms
	_original_outer_transform = transform
	_original_inner_transform = _gimbal_node.transform

# - Runs every frame -
func _process(delta) -> void:
	if _resetting_camera:
		process_reset(delta)

# - Change internal variables when settings were modified -
func _modify_settings() -> void:
	_x_dir             =   -1 if GameSettings.get_setting("Input", "MouseXInverted") else  1
	_y_dir             =    1 if GameSettings.get_setting("Input", "MouseYInverted") else -1
	_mouse_sensitivity = 0.001 * GameSettings.get_setting("Input", "MouseSensitivity")

# - Moves the camera according to mouse input -
func _input(event) -> void:
	if is_current():
		if event is InputEventMouseMotion:
			_resetting_camera = false
			if event.relative.x != 0:
				rotate_object_local(Vector3.UP, _y_dir * event.relative.x * _mouse_sensitivity)
			if event.relative.y != 0:
				_gimbal_node.rotate_object_local(Vector3.RIGHT, _x_dir * event.relative.y * _mouse_sensitivity)

# - Resets the camera to original position -
func reset_camera() -> void:
	_resetting_camera = true

func process_reset(delta) -> void:
	# Check if Gimbals are reset
	var reset_gimbals : int = 0
	if _reset_near_enough(transform.basis, _original_outer_transform.basis, RESET_THRESHOLD):
		reset_gimbals += 1
	if _reset_near_enough(_gimbal_node.transform.basis, _original_inner_transform.basis, RESET_THRESHOLD):
		reset_gimbals += 1
	if reset_gimbals == 2:
		_resetting_camera = false
		return
	# Interpolate further reset
	transform = transform.interpolate_with(_original_outer_transform, RESET_SPEED * delta)
	_gimbal_node.transform = _gimbal_node.transform.interpolate_with(_original_inner_transform, RESET_SPEED * delta)

func _reset_near_enough(a: Transform, b: Transform, threshold: float) -> bool:
	return (
		(a.basis.x - b.basis.x).length() < threshold
		and (a.basis.y - b.basis.y).length() < threshold
		and (a.basis.z - b.basis.z).length() < threshold
	)

# - Active camera property -
func set_current(value) -> void:
	_camera_node.set_current(value)

func make_current() -> void:
	_camera_node.make_current()

func is_current() -> bool:
	return _camera_node.is_current()
