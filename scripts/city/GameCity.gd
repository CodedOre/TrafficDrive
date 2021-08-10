# Copyright 2021, Frederick Schenk

# --- GameCity script ---
# A script with some functions for the city.

extends Spatial

# -- Variables --

# - Internal nodes -
onready var env : WorldEnvironment = $Environment

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	# Connects settings
	GameSettings.connect("setting_changed", self, "_update_settings")

# - Sets the time -
func set_time(time : float) -> void:
	env.time_of_day = time

# - Set the pause on the time -
func set_pause(pause : bool) -> void:
	env.time_paused = pause

# - Updates the render distance -
func _update_settings() -> void:
	var dist_set : int = GameSettings.get_setting("Graphics", "RenderDistance")
	var distance : int = GameSettings.RENDER_DISTANCE_VALUES[dist_set]
	env.environment.fog_depth_end = distance
