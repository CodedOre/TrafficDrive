# Copyright 2021, Frederick Schenk

# --- TitleScreen Script ---
# The script for the first menu.

extends GameState

# -- Signals --
signal start_game()

# -- Functions --

# - Emit signals for other scripts to carry on -
func _close_with_start() -> void:
	emit_signal("start_game")
