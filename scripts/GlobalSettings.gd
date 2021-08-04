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
	# Key binds
	for action in GameSettings._config.get_section_keys("Keys"):
		var input_events = InputMap.get_action_list(action)
		for event in input_events:
			InputMap.action_erase_event(action, event)
		var new_event : InputEventKey = InputEventKey.new()
		new_event.set_scancode(GameSettings.get_setting("Keys", action))
		InputMap.action_add_event(action, new_event)
