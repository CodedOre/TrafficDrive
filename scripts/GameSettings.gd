# Copyright 2021, Frederick Schenk

# --- GameSettings Script ---
# A script for providing settings as well as storing them.

extends Node

# -- Enums --

# - Performance Settings -
enum VehicleLightNode    {OFF, SPOT, FULL}

# -- Constants --

# - File locations -
const DEFAULT_CONFIG_FILE : String =  "res://default_config.cfg"
const    USER_CONFIG_FILE : String = "user://TrafficDrive.cfg"

# -- Variables --

# - ConfigFile class as backend -
var _config : ConfigFile = ConfigFile.new()

# - Settings Storage -
var _storage : Dictionary = {}

# -- Signals --
signal setting_changed()

# -- Functions --

# - Run at startup, check for config file -
func _ready() -> void:
	load_settings()

# - Load from an config file -
func load_settings() -> void:
	# Check if user config exists
	var filecheck   : File = File.new()
	var config_file : String
	if filecheck.file_exists(USER_CONFIG_FILE):
		config_file = USER_CONFIG_FILE
	else:
		config_file = DEFAULT_CONFIG_FILE
	# Loads the configuration into the storage
	if _config.load(config_file) == OK:
		for category in _config.get_sections():
			_storage[category] = {}
			for setting in _config.get_section_keys(category):
				_storage[category][setting] = _config.get_value(category, setting)
	else:
		push_error("Could not load configuration file " + config_file)
	emit_signal("setting_changed")

# - Saves to an config file -
func save_settings() -> void:
	for category in _storage.keys():
		for setting in _storage[category].keys():
			_config.set_value(category, setting, _storage[category][setting])
	_config.save(USER_CONFIG_FILE)

# - Retrieves a setting -
func get_setting(category : String, setting : String):
	return _storage[category][setting]

# - Saves a setting -
func set_setting(category : String, setting : String, value) -> void:
	_storage[category][setting] = value
	emit_signal("setting_changed")
