# Copyright 2021, Frederick Schenk

# --- GlobalSetttings Script ---
# A script for settings that are set via the project.

extends Node

# -- Enums --

# - Graphics Settings -
enum DisplaySetting {WINDOW, BORDERLESS, FULLSCREEN}

# -- Functions --

# - Run at startup -
func _ready() -> void:
	GameSettings.connect("setting_changed", self, "_set_settings")
	_set_settings()

# - Set settings according to the stored value
func _set_settings() -> void:
	# Display setting
	match GameSettings.get_setting("Graphics", "Display"):
		DisplaySetting.WINDOW:
			OS.window_fullscreen = false
			OS.window_borderless = false
		DisplaySetting.BORDERLESS:
			OS.window_fullscreen = false
			OS.window_borderless = true
		DisplaySetting.FULLSCREEN:
			OS.window_fullscreen = true
	OS.vsync_enabled = GameSettings.get_setting("Graphics", "EnableVSync")
