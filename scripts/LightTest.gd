extends Node

enum front_mode {None, Normal, HighBeam}
enum turning    {None, Left, Right}

export (front_mode) var lights
export (bool) var brake
export (turning) var turn
export (bool) var reverse

export (Array, NodePath) onready var all_lights

var all_light_nodes = Array()

func _ready():
	for path in all_lights:
		all_light_nodes.append(get_node(path))
	var light_managment = VehicleLightsManager.new(all_light_nodes)

func _process(_delta):
	pass
