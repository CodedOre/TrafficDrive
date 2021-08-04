# Copyright 2021, Frederick Schenk

# --- PaintPalette Script ---
# Provides various paints for a vehicle

extends Resource
class_name PaintPalette

# -- Constants --

# - Paint Palette -
const DEFAULT_PAINT_PALETTE : Array = Array()

# -- Properties --

# - Paint Palette -
export (Array, Material) var PaintPalette = DEFAULT_PAINT_PALETTE

# -- Methods --

# - Sets the default values -
func _init(
	# Paint Palette
	_paint_palette : Array = DEFAULT_PAINT_PALETTE
) -> void:
	# Paint Palette
	PaintPalette = _paint_palette
