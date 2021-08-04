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
onready var vehicle_lights = $MenuBox/ContentContainer/Graphics/GraphicsGrid/VehLightOptions

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

# - Load the values of the settings -
func _load_settings() -> void:
	_display_vehicle_lights()

# - Calls for an complete settings reset -
func _reset_settings() -> void:
	GameSettings.reset_settings()

# - VehicleLights settings -
func _display_vehicle_lights() -> void:
	vehicle_lights.selected = GameSettings.get_setting("Graphics", "VehicleLights")
func _set_vehicle_lights(setting : int) -> void:
	GameSettings.set_setting("Graphics", "VehicleLights", setting)
