tool
extends Node

enum front_mode {None, Normal, HighBeam}
enum turning    {None, Left, Right}

export (front_mode) var lights
export (bool) var brake
export (turning) var turn
export (bool) var reverse

func _process(_delta):
	pass
