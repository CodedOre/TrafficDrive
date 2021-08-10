# Copyright 2021, Frederick Schenk

# --- CreditsScreen Script ---
# A script to display the credits for this game.

extends Control

# -- Variables --

# - The credits file -
onready var credits : String = "res://credits.tres"

# - Internal nodes -
onready var label : RichTextLabel = $CreditsContainer/MenuBox/ContentContainer/CreditsText

# -- Signals --
signal close_screen()

# -- Functions --

# - Inputs the credits text -
func _ready():
	# Runtime variables
	var text : String = ""
	var file : File   = File.new()
	# Open the file and reads it
	file.open(credits, File.READ)
	while not file.eof_reached():
		var line : String = file.get_line()
		label.append_bbcode(line + "\n")
	# Close the file and displays the text
	file.close()

# - Emit signals for other scripts to carry on -
func _close_to_return() -> void:
	emit_signal("close_screen")
