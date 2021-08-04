# Copyright 2021, Frederick Schenk

# --- SettingsMenu Script ---
# A script for controlling the settings menu.

extends CenterContainer

# -- Enums --

# - The tabs of the menu -
enum SettingTabs {GRAPHICS, GAMEPLAY, INPUT}

# -- Variables --

# - Tab control -
var current_tab # SettingTabs
onready var tab_containers : Dictionary = {
	SettingTabs.GRAPHICS: $MenuBox/ContentContainer/Graphics,
	SettingTabs.GAMEPLAY: $MenuBox/ContentContainer/Gameplay,
	SettingTabs.INPUT:    $MenuBox/ContentContainer/Input
}
onready var tab_selectors : Dictionary = {
	SettingTabs.GRAPHICS: $MenuBox/TabsContainer/GraphicsTab,
	SettingTabs.GAMEPLAY: $MenuBox/TabsContainer/GameplayTab,
	SettingTabs.INPUT:    $MenuBox/TabsContainer/InputTab
}

# - Graphics nodes -
onready var display_options : OptionButton = $MenuBox/ContentContainer/Graphics/GraphicsGrid/DisplayOptions
onready var vsync_option    : CheckBox     = $MenuBox/ContentContainer/Graphics/GraphicsGrid/VSyncCheck
onready var vehicle_lights  : OptionButton = $MenuBox/ContentContainer/Graphics/GraphicsGrid/VehLightOptions

# -- Signals --
signal close_options()

# -- Functions --

# - Runs at startup -
func _ready() -> void:
	# Connect to Settings changes
	GameSettings.connect("setting_changed", self, "_load_settings")
	_load_settings()
	# Select the first tab
	set_tab(SettingTabs.GRAPHICS)

# - Sets the tabs -
func set_tab(selected) -> void:
	for tab in tab_selectors.keys():
		if tab == selected:
			tab_containers[tab].visible = true
			tab_selectors[tab].pressed = true
		else:
			tab_containers[tab].visible = false
			tab_selectors[tab].pressed = false

# - Signals to close the options -
func _close_to_return() -> void:
	emit_signal("close_options")

# - Load the values of the settings -
func _load_settings() -> void:
	_display_display_options()
	_display_vsync_option()
	_display_vehicle_lights()

# - Calls for an complete settings reset -
func _reset_settings() -> void:
	GameSettings.reset_settings()

# - DisplayOption settings -
func _display_display_options() -> void:
	display_options.select(GameSettings.get_setting("Graphics", "Display"))
func _set_display_options(setting : int) -> void:
	GameSettings.set_setting("Graphics", "Display", setting)

# - VSync setting -
func _display_vsync_option() -> void:
	vsync_option.pressed = GameSettings.get_setting("Graphics", "EnableVSync")
func _set_vsync_option(setting : bool) -> void:
	GameSettings.set_setting("Graphics", "EnableVSync", setting)

# - VehicleLights settings -
func _display_vehicle_lights() -> void:
	vehicle_lights.select(GameSettings.get_setting("Graphics", "VehicleLight"))
func _set_vehicle_lights(setting : int) -> void:
	GameSettings.set_setting("Graphics", "VehicleLight", setting)
