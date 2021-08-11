# Copyright 2021, Frederick Schenk

# --- District Script ---
# The script responsible for finding your respawn.

extends Spatial

# -- Signals --
signal district_entered()

# -- Functions --

# - The player is now in this district -
func _district_entered(body) -> void:
	emit_signal("district_entered")
