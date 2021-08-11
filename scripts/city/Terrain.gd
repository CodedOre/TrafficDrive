# Copyright 2021, Frederick Schenk

# --- Terrain Script ---
# The script for the terrain node.

extends Spatial

# -- Signals --
signal request_reset()

# -- Functions --

# - Sends the reset signal -
func _send_reset_request() -> void:
	emit_signal("request_reset")
