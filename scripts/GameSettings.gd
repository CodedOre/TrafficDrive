# Copyright 2021, Frederick Schenk

# --- GameSettings Script ---
# A script for providing settings as well as storing them.

extends Node

# -- Enums --

# - Performance Settings -
enum VehicleLightNode    {OFF, SPOT, FULL}
enum VehicleLightShadows {OFF, SPOT, FULL}

# -- Constants --

# - File locations -
const DEFAULT_CONFIG_FILE =  "res://default_config.cfg"
const    USER_CONFIG_FILE = "user://TrafficDrive.cfg"

# -- Variables --

# - ConfigFile class as backend -
var _config = ConfigFile.new()

# - Settings Storage -
var _storage = {}

# -- Signals --
signal setting_changed()

# -- Functions --

# - Run at startup, check for config file -
func _ready():
	load_settings()

# - Load from an config file -
func load_settings():
	# Check if user config exists
	var filecheck = File.new()
	var config_file
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
func save_settings():
	for category in _storage.keys():
		for setting in _storage[category].keys():
			_config.set_value(category, setting, _storage[category][setting])
	_config.save(USER_CONFIG_FILE)

# - Retrieves a setting -
func get_setting(category : String, setting : String):
	return _storage[category][setting]

# - Saves a setting -
func set_setting(category : String, setting : String, value):
	_storage[category][setting] = value
	emit_signal("setting_changed")
