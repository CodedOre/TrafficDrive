# Copyright 2021, Frederick Schenk

# --- GameSettings Script ---
# A script for providing settings as well as storing them.

extends Node

# -- Enums --

# - Performance Settings -
enum VehicleLightNode    {OFF, SPOT, FULL}

# -- Constants --

# - File locations -
const DEFAULT_CONFIG_FILE : String =  "res://default_config.tres"
const    USER_CONFIG_FILE : String = "user://TrafficDrive.tres"
const    USER_BACKUP_FILE : String = "user://TrafficDrive.bak.tres"

# -- Variables --

# - ConfigFile class as backend -
var _config : ConfigFile = ConfigFile.new()

# -- Signals --
signal setting_changed()

# -- Functions --

# - Run at startup, check the config files -
func _ready() -> void:
	# Method variables
	var filecheck       : File       = File.new()
	var default_config  : ConfigFile = ConfigFile.new()
	var user_configured : bool       = false
	var user_outdated   : bool       = false
	var default_edition : int        = 0
	var user_edition    : int        = 0
	
	# Check if files are available
	if filecheck.file_exists(USER_CONFIG_FILE):
		user_configured = true
	if ! filecheck.file_exists(DEFAULT_CONFIG_FILE):
		push_error("GameSettings: Default config file missing!")
	
	# Load default configuration
	if ! default_config.load(DEFAULT_CONFIG_FILE) == OK:
		push_error("GameSettings: Default config file unreadable!")
		return
	default_edition = default_config.get_value("Meta", "ConfigFileEdition")
	
	# Load (if available) user configuration
	if user_configured and _config.load(USER_CONFIG_FILE) == OK:
		user_edition = _config.get_value("Meta", "ConfigFileEdition")
	
	# Check versions of configuration
	if user_edition < default_edition:
		user_outdated = true
	elif user_edition > default_edition:
		user_configured = false
		push_error( "GameSettings: Bad configuration file! A new configuration will be created.")
		var folder : Directory = Directory.new()
		folder.rename(USER_CONFIG_FILE, USER_BACKUP_FILE)
	
	# Create new user configuration
	if ! user_configured:
		for section in default_config.get_sections():
			for setting in default_config.get_section_keys(section):
				var default_value = default_config.get_value(section, setting)
				_config.set_value(section, setting, default_value)
		_config.save(USER_CONFIG_FILE)
	
	# Add new settings to user config (if outdated)
	if user_outdated:
		for section in default_config.get_sections():
			for setting in default_config.get_section_keys(section):
				if ! _config.has_section_key(section, setting):
					var default_value = default_config.get_value(section, setting)
					_config.set_value(section, setting, default_value)
		_config.set_value("Meta", "ConfigFileEdition", default_edition)
		_config.save(USER_CONFIG_FILE)

func reload_settings() -> void:
	if _config.load(USER_CONFIG_FILE) != OK:
		push_error("GameSettings: Reloading Settings failed!")
	emit_signal("setting_changed")

# - Retrieves a setting -
func get_setting(section : String, setting : String):
	if _config.has_section_key(section, setting):
		return _config.get_value(section, setting)
	else:
		push_error("GameSettings: Setting \"" + section + "/" + setting + "\" could not be found")

# - Saves a setting -
func set_setting(section : String, setting : String, value) -> void:
	if _config.has_section_key(section, setting):
		_config.set_value(section, setting, value)
		_config.save(USER_CONFIG_FILE)
		emit_signal("setting_changed")
	else:
		push_error("GameSettings: Setting \"" + section + "/" + setting + "\" could not be saved")
	
