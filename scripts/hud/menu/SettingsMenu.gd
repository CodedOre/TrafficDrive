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

# -- Functions --

# - Runs at startup -
func _ready() -> void:
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
