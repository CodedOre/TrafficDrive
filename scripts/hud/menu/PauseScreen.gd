# Copyright 2021, Frederick Schenk

# --- PauseScreen Script ---
# A script for controlling the pause functionality.

extends Control

# -- Signals --
signal resume_action()
signal return_to_main()

# -- Functions --

# - Emit signals for other scripts to carry on -
func _close_with_resume() -> void:
	emit_signal("resume_action")
func _close_with_main() -> void:
	emit_signal("return_to_main")
