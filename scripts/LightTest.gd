extends Node

enum front_mode {None, Normal, HighBeam}
enum turning    {None, Left, Right}

export (front_mode) var lights
export (bool) var brake
export (turning) var turn
export (bool) var reverse

export (Array, NodePath) onready var all_lights

func _process(_delta):
	var light_managment = VehicleLightsManager.new()
