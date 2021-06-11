# Copyright 2021, Frederick Schenk

# --- OuterMirror Script ---
# The script for a simple mirror.

extends Control

# -- Properties --

# - The vehicle using this mirror -
var DisplayedVehicle : Vehicle setget set_displayed_vehicle, get_displayed_vehicle

# -- Variables --

# - Internal nodes -
onready var _mirror_camera   : Camera    = $Viewport/MirrorCam
onready var _mirror_viewport : Viewport  = $Viewport
onready var _mirror_texture  : Polygon2D = $Mirror

# - Runtime variables -
var _mirror_active     : bool
var _displayed_vehicle : Vehicle
var _mirror_point      : CameraPoint

# -- Functions --

# - Runs at start up -
func _ready() -> void:
	GameSettings.connect("setting_changed", self, "_modify_settings")

# - Runs at every frame -
func _process(_delta) -> void:
	if _mirror_active:
		# Follow the camera point
		_mirror_camera.global_transform = _nonrot_transform(_mirror_point)

# - Returns a Transform tha is at a Node's position, but only y rotation -
func _nonrot_transform(base : Spatial) -> Transform:
	var position : Vector3 = base.global_transform.origin
	var y_rotate : float   = base.global_transform.basis.get_euler().y
	return Transform(Basis(Vector3.UP, y_rotate), position)

# - Change internal variables when settings were modified -
func _modify_settings() -> void:
	_mirror_active = GameSettings.get_setting("Performance", "OuterMirrorActive")
	if _mirror_active:
		if _displayed_vehicle._outer_mirror_point != null:
			_mirror_point = _displayed_vehicle._outer_mirror_point
			_mirror_texture.texture = _mirror_viewport.get_texture()
			visible = true
	else:
		_mirror_texture.texture = null
		visible = false

# - DisplayedVehicle property -
func set_displayed_vehicle(node : Vehicle) -> void:
	_displayed_vehicle = node
	_modify_settings()

func get_displayed_vehicle() -> Vehicle:
	return _displayed_vehicle
