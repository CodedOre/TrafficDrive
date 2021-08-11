# Copyright 2021, Frederick Schenk

# --- VehicleSelect Script ---
# The script for selecting a vehicle.

extends GameState

# -- Constants --

# - Speed the camera resets -
const MOVE_SPEED     : float = 4.0
const MOVE_THRESHOLD : float = 0.02

# -- Properties --

# - All vehicles to be selected -
export (Dictionary) var VehicleViews = Dictionary()

# -- Variables --

# - VehicleViews storage -
var vehicle_pool  : Array = Array()
var viewport_pool : Array = Array()

# - Internal nodes -
onready var camera : Camera = $Camera

# - HUD nodes -
onready var back_button   : Button       = $HUD/Selector/BackButton
onready var next_button   : Button       = $HUD/Selector/NextButton
onready var name_label    : Label        = $HUD/Selector/NameBox/VehicleName
onready var info_label    : Label        = $HUD/SideContainer/InfoContainer/InfoLabel
onready var color_option  : OptionButton = $HUD/SideContainer/ColorOption

# - Runtime variables -
var selected_vehicle   : int  = 0
var interpolate_view   : bool = false
var viewport_transform : Transform

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
	select_vehicle(0, true)
	# Connects GameSettings changes
	GameSettings.connect("setting_changed", self, "_update_settings")

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
		camera.global_transform = viewport_transform
	else:
		interpolate_view = true
	# Set HUD elements
	var vehicle_lenght : int = vehicle_pool.size() - 1
	back_button.disabled = true if selected_vehicle == 0 else false
	next_button.disabled = true if selected_vehicle == vehicle_lenght else false
	name_label.text = vehicle_pool[selected_vehicle].VehicleName
	info_label.text = vehicle_pool[selected_vehicle].VehicleInfo
	# Set paint options
	color_option.clear()
	var palette : PaintPalette = vehicle_pool[selected_vehicle].PaintPalette
	for paint in palette.PaintPalette:
		var name : String = paint.resource_path.get_file().trim_suffix('.material')
		color_option.add_item(name)
	color_option.select(vehicle_pool[selected_vehicle].VehiclePaint)

# - Signals changes to 'Main'
func return_to_main() -> void:
	emit_signal("menu_return")
func confirm_vehicle() -> void:
	emit_signal("menu_confirm")

# - Interpolates camera -
func _process(delta: float) -> void:
	if interpolate_view:
		camera.global_transform = camera.global_transform.interpolate_with(
			viewport_transform, MOVE_SPEED * delta)
		if _transforms_close(camera.global_transform, viewport_transform, MOVE_THRESHOLD):
			interpolate_view = false

# - If a transform is near of another -
func _transforms_close(a : Transform, b : Transform, threshold : float) -> bool:
	return (
		(a.basis.x - b.basis.x).length() < threshold
		and (a.basis.y - b.basis.y).length() < threshold
		and (a.basis.z - b.basis.z).length() < threshold
		and (a.origin  - b.origin).length()  < threshold
	)

# - Returns selected settings -
func chosen_vehicle() -> String:
	return vehicle_pool[selected_vehicle].filename
func chosen_paint() -> int:
	return color_option.selected
func vehicle_spawn() -> Transform:
	return vehicle_pool[selected_vehicle].global_transform

# - Sets the paint of the vehicle -
func set_paint(index : int):
	vehicle_pool[selected_vehicle].VehiclePaint = index

# - Updates the camera render distance -
func _update_settings() -> void:
	var dist_set : int = GameSettings.get_setting("Graphics", "RenderDistance")
	var distance : int = GameSettings.RENDER_DISTANCE_VALUES[dist_set]
	$Camera.far   = distance
