# Copyright 2021, Frederick Schenk

# --- GraphicsDebug Script ---
# A script to manage the debug screen for the Graphics.

extends GridContainer

# -- Functions --

# - Runs every frame -
func _process(_delta):
	$FPSValue.text = str(Performance.get_monitor(Performance.TIME_FPS))
