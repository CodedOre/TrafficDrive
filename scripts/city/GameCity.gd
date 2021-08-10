# Copyright 2021, Frederick Schenk

# --- GameCity script ---
# A script with some functions for the city.

extends Spatial

# -- Variables --

# - Internal nodes -
onready var env : WorldEnvironment = $Environment

# -- Functions --

# - Sets the time -
func set_time(time : float) -> void:
	env.time_of_day = time

# - Set the pause on the time -
func set_pause(pause : bool) -> void:
	env.time_paused = pause
