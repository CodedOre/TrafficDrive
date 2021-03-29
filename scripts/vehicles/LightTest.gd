extends Node

export (Array, NodePath) onready var all_lights

var all_light_nodes = Array()
var light_managment

func _ready():
	for path in all_lights:
		all_light_nodes.append(get_node(path))
	light_managment = VehicleLightsManager.new(self, all_light_nodes)

func toggle_nightlight():
	match light_managment.NightLights:
		VehicleLightsManager.NightLightMode.OFF:
			light_managment.NightLights = VehicleLightsManager.NightLightMode.ON
		VehicleLightsManager.NightLightMode.ON:
			light_managment.NightLights = VehicleLightsManager.NightLightMode.FAR
		VehicleLightsManager.NightLightMode.FAR:
			light_managment.NightLights = VehicleLightsManager.NightLightMode.OFF

func toggle_brakelights():
	light_managment.BrakeLights = ! light_managment.BrakeLights

func toggle_reverselights():
	light_managment.ReverseLights = ! light_managment.ReverseLights

func toggle_leftturn():
	light_managment.TurnLeftLights = ! light_managment.TurnLeftLights

func toggle_righturn():
	light_managment.TurnRightLights = ! light_managment.TurnRightLights