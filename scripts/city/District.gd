# Copyright 2021, Frederick Schenk

# --- District Script ---
# The script responsible for finding your respawn.

extends Spatial

# -- Properties --

# - Where a vehicle can (and can't) spawn -
export (NodePath)        var    SpawnGrid
export (Array, NodePath) var NonSpawnGrid

# -- Variables --

# - Where a vehicle can (and can't) spawn -
var     _spawn_grid : GridMap
var _non_spawn_grid : Array = Array()

# -- Signals --
signal district_entered()

# -- Functions --

# - Runs at startup -
func _ready():
	# Check SpawnGrid
	if SpawnGrid == null:
		push_error("District: Non-valid SpawnGrid!")
		return
	var spawn_grid = get_node(SpawnGrid)
	if ! spawn_grid is GridMap:
		push_error("District: Non-valid SpawnGrid!")
		return
	_spawn_grid = spawn_grid
	# Check NonSpawngrid
	if NonSpawnGrid == null or NonSpawnGrid.size() == 0:
		push_error("District: Non-valid SpawnGrid!")
		return
	for grid in NonSpawnGrid:
		var grid_node = get_node(grid)
		if ! grid_node is GridMap:
			push_error("District: Non-valid NonSpawnGrid!")
			return
		_non_spawn_grid.append(grid_node)

# - The player is now in this district -
func _district_entered(body) -> void:
	emit_signal("district_entered")

# - Finds a suitable respawn point for the player -
func get_respawn_point(vehicle_pos: Transform) -> Transform:
	var closest_distance : float   = 9999
	var closest_grid     : Vector3
	# Find the nearest ground grid to spawn on
	for ground in _spawn_grid.get_used_cells():
		# Check the distance to vehicle_pos
		var ground_pos      : Vector3 = _spawn_grid.map_to_world(ground.x, ground.y, ground.z)
		var ground_distance : float   = ground_pos.distance_to(vehicle_pos.origin)
		# If nearest distance yet...
		if ground_distance < closest_distance:
			# Check if grid has no elements on top
			var possible_spawn : bool = true
			for height in range(ground.y, 20):
				if _spawn_grid.get_cell_item(ground.x, height + 1, ground.z) != -1:
					possible_spawn = false
					break
				for grid in _non_spawn_grid:
					if grid.get_cell_item(ground.x, height, ground.z) != -1:
						possible_spawn = false
						break
			if possible_spawn:
				closest_distance = ground_distance
				closest_grid = ground
	# Create transform for spawn pos
	var spawn_position : Vector3 = _spawn_grid.map_to_world(closest_grid.x, closest_grid.y, closest_grid.z)
	return Transform(Basis(), spawn_position)
