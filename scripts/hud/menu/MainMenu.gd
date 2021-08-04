# Copyright 2021, Frederick Schenk

# --- MainMenu Script ---
# A script for forwarding signals from the main menu.

extends CenterContainer

# -- Signals --
signal start_game()
signal open_options()

# -- Functions --

# - Emit signals for other scripts to carry on -
func _close_with_start() -> void:
	emit_signal("start_game")
func _close_with_options() -> void:
	emit_signal("open_options")

# Quits the game
func _close_with_quit() -> void:
	get_tree().quit()
