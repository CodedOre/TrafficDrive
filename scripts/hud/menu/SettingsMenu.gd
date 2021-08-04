# Copyright 2021, Frederick Schenk

# --- SettingsMenu Script ---
# A script for controlling the settings menu.

extends Control

# -- Enums --

# - The tabs of the menu -
enum SettingTabs {GRAPHICS, GAMEPLAY, INPUT, KEYS}

# -- Properties --

# - If _input is used -
export (bool) var ParseInput = true

# -- Variables --

# - Tab control -
var current_tab # SettingTabs
onready var tab_containers : Dictionary = {
	SettingTabs.GRAPHICS: $SettingsContainer/MenuBox/ContentContainer/Graphics,
	SettingTabs.GAMEPLAY: $SettingsContainer/MenuBox/ContentContainer/Gameplay,
	SettingTabs.INPUT:    $SettingsContainer/MenuBox/ContentContainer/Input,
	SettingTabs.KEYS:     $SettingsContainer/MenuBox/ContentContainer/Keys
}
onready var tab_selectors : Dictionary = {
	SettingTabs.GRAPHICS: $SettingsContainer/MenuBox/TabsContainer/GraphicsTab,
	SettingTabs.GAMEPLAY: $SettingsContainer/MenuBox/TabsContainer/GameplayTab,
	SettingTabs.INPUT:    $SettingsContainer/MenuBox/TabsContainer/InputTab,
	SettingTabs.KEYS:     $SettingsContainer/MenuBox/TabsContainer/KeysTab
}

# - Input actions -
onready var changeable_inputs : Dictionary = {
	"vehicle_movement_forward": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/ForwardButton,
	"vehicle_movement_backward": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/BackwardsButton,
	"vehicle_movement_left": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/SteerLeftButton,
	"vehicle_movement_right": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/SteerRightButton,
	"vehicle_gear_up": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/GearUpButton,
	"vehicle_gear_down": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/GearDownButton,
	"vehicle_light_night": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/HeadlightsButton,
	"vehicle_light_turn_left": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/TurnLeftButton,
	"vehicle_light_turn_right": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/TurnRightButton,
	"vehicle_light_hazards": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/HazardsButton,
	"vehicle_change_camera": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/CameraButton,
	"vehicle_set_cruise_control": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/CruiseControlButton,
	"vehicle_increase_cruise_control": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/CruiseUpButton,
	"vehicle_decrease_cruise_control": $SettingsContainer/MenuBox/ContentContainer/Keys/ScrollContainer/KeysGrid/CruiseDownButton
}

# - Graphics nodes -
onready var display_options : OptionButton = $SettingsContainer/MenuBox/ContentContainer/Graphics/GraphicsGrid/DisplayOptions
onready var vsync_option    : CheckBox     = $SettingsContainer/MenuBox/ContentContainer/Graphics/GraphicsGrid/VSyncCheck
onready var vehicle_lights  : OptionButton = $SettingsContainer/MenuBox/ContentContainer/Graphics/GraphicsGrid/VehLightOptions

# - Gameplay nodes -
onready var automatic_option : CheckBox = $SettingsContainer/MenuBox/ContentContainer/Gameplay/AutoGearCheck
onready var imperial_option  : CheckBox = $SettingsContainer/MenuBox/ContentContainer/Gameplay/ImperialCheck
onready var mirror_option    : CheckBox = $SettingsContainer/MenuBox/ContentContainer/Gameplay/MirrorCheck

# - Input nodes -
onready var invert_option      : CheckBox = $SettingsContainer/MenuBox/ContentContainer/Input/InvertCheck
onready var sensitivity_value  : Label    = $SettingsContainer/MenuBox/ContentContainer/Input/SensitivityBox/SensitivityValue
onready var sensitivity_slider : HSlider  = $SettingsContainer/MenuBox/ContentContainer/Input/SensitivityBox/SensitivitySlider

# - Key nodes -
onready var change_key_panel : Control = $ChangeKeys

# - Runtime variables -
var changing_input : bool   = false
var changed_action : String = ""

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
	invert_option.pressed = GameSettings.get_setting("Input", "MouseXInverted")
	sensitivity_slider.value = GameSettings.get_setting("Input", "MouseSensitivity")
	sensitivity_value.text = str(sensitivity_slider.value)
	_display_set_keys()

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
func _set_invert_option(setting : bool) -> void:
	GameSettings.set_setting("Input", "MouseXInverted", setting)
func _set_mouse_sensitivity(setting : float) -> void:
	GameSettings.set_setting("Input", "MouseSensitivity", setting)

# - Calls for an complete settings reset -
func _reset_settings() -> void:
	GameSettings.reset_settings()

# - Sets the values for the keybind buttons -
func _display_set_keys() -> void:
	for action in changeable_inputs.keys():
		var input_button : Button = changeable_inputs[action]
		var input_event  : int    = GameSettings.get_setting("Keys", action)
		input_button.text = OS.get_scancode_string(input_event)

# - Activates the "Change Keybind screen" -
func _change_keybind(action : String):
	changed_action = action
	change_key_panel.visible = true
	changing_input = true

# - Detects input when changing keybinds -
func _input(event):
	# Check if valid input
	if ! ParseInput:
		return
	if ! event.is_pressed():
		return
	# Close options when not changing keys
	if ! changing_input:
		if event.is_action("ui_cancel"):
			emit_signal("close_options")
	# Change keys (or abort when Esc)
	if changing_input and event.is_pressed():
		if ! event.is_action("ui_cancel"):
			GameSettings.set_setting("Keys", changed_action, event.scancode)
		_close_keybind()

# - Closes the "Change Keybind screen" -
func _close_keybind():
	changing_input = false
	changed_action = ""
	change_key_panel.visible = false
