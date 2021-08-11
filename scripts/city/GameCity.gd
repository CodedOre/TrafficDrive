# Copyright 2021, Frederick Schenk

# --- GameCity script ---
# A script with some functions for the city.

extends Spatial

# -- Variables --

# - Internal nodes -
onready var districts : Node             = $Districts
onready var env       : WorldEnvironment = $Environment

# - Runtime states -
var active_district : Spatial

# -- Signal --
signal request_reset()

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	# Connects settings
	GameSettings.connect("setting_changed", self, "_update_settings")
	# Connects all districts
	for area in districts.get_children():
		area.connect("district_entered", self, "set_active_district", [area])

# - Sets the time -
func set_time(time : float) -> void:
	env.time_of_day = time

# - Set the pause on the time -
func set_pause(pause : bool) -> void:
	env.time_paused = pause

# - Updates the render distance -
func _update_settings() -> void:
	# Set RenderDistance
	var dist_set : int = GameSettings.get_setting("Graphics", "RenderDistance")
	var distance : int = GameSettings.RENDER_DISTANCE_VALUES[dist_set]
	env.environment.fog_depth_end = distance
	# Set SSAO
	env.environment.ssao_enabled = GameSettings.get_setting("Graphics", "EnableSSAO")

# - Set the current active district -
func set_active_district(district: Spatial) -> void:
	active_district = district

# - Gets the respawn position for the vehicle -
func get_respawn_position(vehicle_pos: Transform) -> Transform:
	return active_district.get_respawn_point(vehicle_pos)

# - Emits the "request_reset" signal
func _send_reset_request() -> void:
	emit_signal("request_reset")
