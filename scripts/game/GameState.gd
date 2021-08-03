# Copyright 2021, Frederick Schenk

# --- GameState Script ---
# The script for a state of an game.

extends Spatial
class_name GameState

# -- Properties --

# - The camera for this state -
export (NodePath) var StateCamera

# -- Variables --

# - Internal nodes -
var _state_camera : Spatial

# -- Functions --

# - Runs on startup -
func _ready() -> void:
	_state_camera = get_node(StateCamera)
	if _state_camera == null:
		push_error("GameState: No StateCamera given!")
