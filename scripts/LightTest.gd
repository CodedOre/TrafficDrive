extends Node

export (Array, NodePath) onready var all_lights

var all_light_nodes = Array()
var light_managment

func _ready():
	for path in all_lights:
		all_light_nodes.append(get_node(path))
	light_managment = VehicleLightsManager.new(all_light_nodes)

func toggle_nightlight():
	match light_managment.nightlights:
		VehicleLightsManager.NightLightMode.OFF:
			light_managment.nightlights = VehicleLightsManager.NightLightMode.ON
		VehicleLightsManager.NightLightMode.ON:
			light_managment.nightlights = VehicleLightsManager.NightLightMode.FAR
		VehicleLightsManager.NightLightMode.FAR:
			light_managment.nightlights = VehicleLightsManager.NightLightMode.OFF

func toggle_brakelights():
	light_managment.brakelights = ! light_managment.brakelights
