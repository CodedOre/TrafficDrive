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

# - Gameplay nodes -
onready var automatic_option : CheckBox = $MenuBox/ContentContainer/Gameplay/AutoGearCheck
onready var imperial_option  : CheckBox = $MenuBox/ContentContainer/Gameplay/ImperialCheck
onready var mirror_option    : CheckBox = $MenuBox/ContentContainer/Gameplay/MirrorCheck

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
	display_options.select(GameSettings.get_setting("Graphics", "Display"))
	vsync_option.pressed = GameSettings.get_setting("Graphics", "EnableVSync")
	vehicle_lights.select(GameSettings.get_setting("Graphics", "VehicleLight"))
	automatic_option.pressed = GameSettings.get_setting("Gameplay", "SwitchGearsAutomatically")
	imperial_option.pressed = GameSettings.get_setting("Gameplay", "UseImperialUnits")
	mirror_option.pressed = GameSettings.get_setting("Gameplay", "OuterMirrorActive")

# - Sets the settings to the wanted value -
func _set_display_options(setting : int) -> void:
	GameSettings.set_setting("Graphics", "Display", setting)
func _set_vsync_option(setting : bool) -> void:
	GameSettings.set_setting("Graphics", "EnableVSync", setting)
func _set_vehicle_lights(setting : int) -> void:
	GameSettings.set_setting("Graphics", "VehicleLight", setting)
func _set_automatic_gears(setting : bool) -> void:
	GameSettings.set_setting("Gameplay", "SwitchGearsAutomatically", setting)
func _set_imperial_units(setting : bool) -> void:
	GameSettings.set_setting("Gameplay", "UseImperialUnits", setting)
func _set_mirror_option(setting : bool) -> void:
	GameSettings.set_setting("Gameplay", "OuterMirrorActive", setting)

# - Calls for an complete settings reset -
func _reset_settings() -> void:
	GameSettings.reset_settings()
