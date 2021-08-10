# Copyright 2021, Frederick Schenk

# --- TitleScreen Script ---
# The script for the first menu.

extends GameState

# -- Variables --

# - Runtime states -
var open_options : bool = false
var open_credits : bool = false

# -- Signals --
signal start_game()

# -- Functions --

# - Runs at startup -
func _ready():
	# Connects GameSettings changes
	GameSettings.connect("setting_changed", self, "_update_settings")

# - Emit signals for other scripts to carry on -
func _close_with_start() -> void:
	emit_signal("start_game")

# - Toggles the visibility of the settings menu -
func _toggle_options() -> void:
	open_options = ! open_options
	$MainMenu.visible     = ! open_options
	$SettingsMenu.visible =   open_options

# - Toggles the visibility of the credits screen -
func _toggle_credits() -> void:
	open_credits = ! open_credits
	$MainMenu.visible      = ! open_credits
	$CreditsScreen.visible =   open_credits

# - Updates the camera render distance -
func _update_settings() -> void:
	var dist_set : int = GameSettings.get_setting("Graphics", "RenderDistance")
	var distance : int = GameSettings.RENDER_DISTANCE_VALUES[dist_set]
	$Camera.far   = distance
