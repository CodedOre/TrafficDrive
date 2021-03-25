extends Node

export (Array, NodePath) onready var all_lights

var all_light_nodes = Array()
var light_managment

func _ready():
	for path in all_lights:
		all_light_nodes.append(get_node(path))
	light_managment = VehicleLightsManager.new(all_light_nodes)
#	light_managment.frontlight_mode = VehicleLightsManager.FrontLightMode.OFF

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		match light_managment.frontlight_mode:
			VehicleLightsManager.FrontLightMode.OFF:
				light_managment.frontlight_mode = VehicleLightsManager.FrontLightMode.HEADLIGHT
			VehicleLightsManager.FrontLightMode.HEADLIGHT:
				light_managment.frontlight_mode = VehicleLightsManager.FrontLightMode.HIGHBEAM
			VehicleLightsManager.FrontLightMode.HIGHBEAM:
				light_managment.frontlight_mode = VehicleLightsManager.FrontLightMode.OFF
