# Copyright 2021, Frederick Schenk

# --- TitleScreen Script ---
# The script for the first menu.

extends GameState

# -- Variables --

# - Runtime states -
var open_options : bool = false

# -- Signals --
signal start_game()

# -- Functions --

# - Emit signals for other scripts to carry on -
func _close_with_start() -> void:
	emit_signal("start_game")

# - Toggles the visibility of the settings menu -
func _toggle_options():
	open_options = ! open_options
	$MainMenu.visible     = ! open_options
	$SettingsMenu.visible =   open_options
