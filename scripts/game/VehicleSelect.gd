# Copyright 2021, Frederick Schenk

# --- VehicleSelect Script ---
# The script for selecting a vehicle.

extends Spatial

# -- Constants --

# - Speed the camera resets -
const MOVE_SPEED     : float = 4.0
const MOVE_THRESHOLD : float = 0.02

# -- Properties --

# - All vehicles to be selected -
export (Dictionary) var VehicleViews = Dictionary()
export (bool)       var DisplayHUD   setget set_display_hud, get_display_hud

# -- Variables --

# - VehicleViews storage -
var vehicle_pool  : Array = Array()
var viewport_pool : Array = Array()

# - HUD nodes -
onready var back_button   : Button       = $HUD/Selector/BackButton
onready var next_button   : Button       = $HUD/Selector/NextButton
onready var name_label    : Label        = $HUD/Selector/NameBox/VehicleName
onready var info_label    : Label        = $HUD/SideContainer/InfoContainer/InfoLabel
onready var color_option  : OptionButton = $HUD/SideContainer/ColorOption

# - Runtime variables -
var selected_vehicle   : int  = 0
var display_hud        : bool = false
var interpolate_view   : bool = false
var viewport_transform : Transform
var camera_transform   : Transform

# -- Signals --
signal menu_return()
signal menu_confirm()

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	# Detect all vehicles and check for CameraPoint
	for vehicle in VehicleViews.keys():
		if ! vehicle is NodePath or ! VehicleViews[vehicle] is NodePath:
			push_error("VehicleSelect: VehicleViews contains non-NodePath!")
			return
		if ! get_node(vehicle) is Vehicle or ! get_node(VehicleViews[vehicle]) is Position3D:
			push_error("VehicleSelect: No valid format of VehicleViews (Correct would be [Vehicle : Position3D])")
			return
		vehicle_pool.append(get_node(vehicle))
		viewport_pool.append(get_node(VehicleViews[vehicle]))
	set_display_hud(display_hud)
	select_vehicle(0, true)

# - Moves the selection -
func move_selection(index: int) -> void:
	var new_select = selected_vehicle + index
	if new_select < 0:
		new_select = 0
	if new_select >= vehicle_pool.size():
		new_select = vehicle_pool.size() - 1
	select_vehicle(new_select)

# - Select a new vehicle -
func select_vehicle(index: int, fast: bool = false) -> void:
	selected_vehicle = index
	# Set camera to viewport
	viewport_transform = viewport_pool[selected_vehicle].global_transform
	if fast:
		camera_transform = viewport_transform
	else:
		interpolate_view = true
	# Set HUD elements
	var vehicle_lenght : int = vehicle_pool.size() - 1
	back_button.disabled = true if selected_vehicle == 0 else false
	next_button.disabled = true if selected_vehicle == vehicle_lenght else false
	name_label.text = vehicle_pool[selected_vehicle].VehicleName
	info_label.text = vehicle_pool[selected_vehicle].VehicleInfo

# - Signals changes to 'Main'
func return_to_main() -> void:
	emit_signal("menu_return")
func confirm_vehicle() -> void:
	emit_signal("menu_confirm")

# - Interpolates camera -
func _process(delta: float) -> void:
	if interpolate_view:
		camera_transform = camera_transform.interpolate_with(
			viewport_transform, MOVE_SPEED * delta)
		if _transforms_close(camera_transform, viewport_transform, MOVE_THRESHOLD):
			interpolate_view = false

# - If a transform is near of another -
func _transforms_close(a : Transform, b : Transform, threshold : float) -> bool:
	return (
		(a.basis.x - b.basis.x).length() < threshold
		and (a.basis.y - b.basis.y).length() < threshold
		and (a.basis.z - b.basis.z).length() < threshold
		and (a.origin  - b.origin).length()  < threshold
	)

# - Returns selected vehicle file -
func chosen_vehicle() -> String:
	return vehicle_pool[selected_vehicle].filename

# - Returns the wanted camera transform -
func wanted_transform() -> Transform:
	return camera_transform

# - DisplayHUD property -
func get_display_hud() -> bool:
	return display_hud

func set_display_hud(displaying: bool) -> void:
	display_hud = displaying
	$HUD.visible = display_hud
	if display_hud:
		var vehicle_lenght : int = vehicle_pool.size() - 1
		back_button.disabled = true if selected_vehicle == 0 else false
		next_button.disabled = true if selected_vehicle == vehicle_lenght else false
	else:
		back_button.disabled = false
		next_button.disabled = false