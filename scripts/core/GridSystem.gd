extends Node2D

class_name GridSystem

var CELL_SIZE: Vector2 = Vector2(64, 64)
var grid_size: Vector2i = Vector2i(16, 16)
var terrain_map: Array = []
var terrain_costs: Dictionary = {
	"plains": 1,
	"forest": 2,
	"mountains": 3,
	"water": 99,  # Impassable for most units
	"wall": 99    # Impassable
}

# Movement and range highlights
var movement_tiles: Array = []
var attack_tiles: Array = []

var astar: AStar2D = AStar2D.new()

# Signals
signal grid_initialized
signal path_found(path: Array)

@onready var unit_manager: UnitManager = $"../UnitManager"

func _ready():
	# Initialize grid when ready
	# Set the z_index to ensure this node draws between terrain and units
	z_index = 1
	# Add signal connection
	unit_manager.unit_moved.connect(_on_unit_moved)

func initialize_grid(size: Vector2i) -> void:
	grid_size = size
	terrain_map.resize(size.x)
	
	for x in range(size.x):
		terrain_map[x] = []
		terrain_map[x].resize(size.y)
		
		for y in range(size.y):
			# Default terrain is plains
			terrain_map[x][y] = "plains"
	
	# Initialize AStar pathfinding
	initialize_astar()
	
	# Signal that grid is initialized
	grid_initialized.emit()

func reset() -> void:
	terrain_map.clear()
	movement_tiles.clear()
	attack_tiles.clear()
	
	astar = AStar2D.new()

func initialize_astar() -> void:
	astar.clear()
	
	# Add points for each grid cell
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var point_id = get_point_id(Vector2i(x, y))
			astar.add_point(point_id, Vector2(x, y))
	
	# Connect points (4-way adjacency)
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var current_pos = Vector2i(x, y)
			var point_id = get_point_id(current_pos)
			
			# Connect to adjacent cells
			var adjacent_cells = [
				Vector2i(x + 1, y),
				Vector2i(x - 1, y),
				Vector2i(x, y + 1),
				Vector2i(x, y - 1)
			]
			
			for adjacent in adjacent_cells:
				if is_within_grid(adjacent):
					var adjacent_id = get_point_id(adjacent)
					
					# Check for enemy units using UnitManager
					var unit = unit_manager.get_unit_at(adjacent)
					if unit and unit.faction == GameUnit.Faction.ENEMY:
						continue  # Skip creating connection entirely for enemy positions
					
					# Get movement cost for this connection
					var terrain_type = terrain_map[adjacent.x][adjacent.y]
					var weight = terrain_costs.get(terrain_type, 1)
					
					# Skip impassable terrain
					if weight >= 99:
						continue
					
					# Connect points with appropriate weight
					if not astar.are_points_connected(point_id, adjacent_id):
						astar.connect_points(point_id, adjacent_id, true)
						astar.set_point_weight_scale(adjacent_id, weight)

func get_point_id(grid_pos: Vector2i) -> int:
	return grid_pos.y * grid_size.x + grid_pos.x

func is_within_grid(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < grid_size.x and grid_pos.y >= 0 and grid_pos.y < grid_size.y

func world_to_grid(world_pos: Vector2i) -> Vector2i:
	var x = int(world_pos.x / CELL_SIZE.x)
	var y = int(world_pos.y / CELL_SIZE.y)
	return Vector2i(x, y)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var x = grid_pos.x * CELL_SIZE.x + CELL_SIZE.x / 2
	var y = grid_pos.y * CELL_SIZE.y + CELL_SIZE.y / 2
	return Vector2(x, y)

func grid_to_world_centered(grid_pos: Vector2i) -> Vector2:
	var x = (grid_pos.x * CELL_SIZE.x + CELL_SIZE.x / 2) + CELL_SIZE.x / 2
	var y = (grid_pos.y * CELL_SIZE.y + CELL_SIZE.y / 2) + CELL_SIZE.y / 2
	return Vector2(x, y)

func get_terrain_at(grid_pos: Vector2i) -> String:
	if is_within_grid(grid_pos):
		return terrain_map[grid_pos.x][grid_pos.y]
	return "invalid"

func set_terrain_at(grid_pos: Vector2i, terrain_type: String) -> void:
	if is_within_grid(grid_pos):
		terrain_map[grid_pos.x][grid_pos.y] = terrain_type
		
		# Update pathfinding weight
		var point_id = get_point_id(grid_pos)
		var weight = terrain_costs.get(terrain_type, 1)
		astar.set_point_weight_scale(point_id, weight)

func calculate_movement_range(unit_pos: Vector2i, movement_points: int) -> Array:
	var reachable_cells = []
	var open_set = [unit_pos]
	var closed_set = {}
	var costs = {get_point_id(unit_pos): 0}
	
	while not open_set.is_empty():
		var current = open_set.pop_front()
		var current_id = get_point_id(current)
		
		if closed_set.has(current_id):
			continue
			
		closed_set[current_id] = true
		reachable_cells.append(current)
		
		var adjacent_cells = [
			Vector2i(current.x + 1, current.y),
			Vector2i(current.x - 1, current.y),
			Vector2i(current.x, current.y + 1),
			Vector2i(current.x, current.y - 1)
		]
		
		for adjacent in adjacent_cells:
			if not is_within_grid(adjacent):
				continue
				
			var adjacent_id = get_point_id(adjacent)
			
			if closed_set.has(adjacent_id):
				continue
				
			var terrain_type = terrain_map[adjacent.x][adjacent.y]
			var move_cost = terrain_costs.get(terrain_type, 1)
			
			# Check for enemy units using UnitManager
			var unit = unit_manager.get_unit_at(adjacent)
			if unit and unit.faction == GameUnit.Faction.ENEMY:
				continue  # Skip enemy positions
			
			# Skip impassable terrain
			if move_cost >= 99:
				continue
				
			var new_cost = costs[current_id] + move_cost
			
			if new_cost <= movement_points and (not costs.has(adjacent_id) or new_cost < costs[adjacent_id]):
				costs[adjacent_id] = new_cost
				open_set.append(adjacent)
	
	# Remove starting position from reachable cells
	reachable_cells.remove_at(0)
	
	return reachable_cells

func calculate_attack_range(positions: Array, min_range: int, max_range: int) -> Array:
	var attack_cells = []
	
	for pos in positions:
		for x in range(pos.x - max_range, pos.x + max_range + 1):
			for y in range(pos.y - max_range, pos.y + max_range + 1):
				var check_pos = Vector2i(x, y)
				
				if not is_within_grid(check_pos):
					continue
					
				var distance = get_distance(pos, check_pos)
				
				if distance >= min_range and distance <= max_range:
					if not attack_cells.has(check_pos):
						attack_cells.append(check_pos)
	
	return attack_cells

# Get Manhattan distance between two grid positions
func get_distance(from_pos: Vector2i, to_pos: Vector2i) -> int:
	return abs(from_pos.x - to_pos.x) + abs(from_pos.y - to_pos.y)

func find_path(from_pos: Vector2i, to_pos: Vector2i) -> Array:
	if not is_within_grid(from_pos) or not is_within_grid(to_pos):
		return []
		
	var from_id = get_point_id(from_pos)
	var to_id = get_point_id(to_pos)
	
	var astar_path = astar.get_point_path(from_id, to_id)
	var grid_path = []
	
	for point in astar_path:
		grid_path.append(Vector2i(int(point.x), int(point.y)))
	
	path_found.emit(grid_path)
	return grid_path

func highlight_movement_range(cells: Array) -> void:
	movement_tiles = cells
	queue_redraw()

func highlight_attack_range(cells: Array) -> void:
	attack_tiles = cells
	queue_redraw()

func clear_highlights() -> void:
	movement_tiles.clear()
	attack_tiles.clear()
	queue_redraw()

func _draw() -> void:
	# Draw movement range
	for cell in movement_tiles:
		var worldPos = grid_to_world(cell)
		var rect = Rect2(
			worldPos.x,
			worldPos.y,
			CELL_SIZE.x,
			CELL_SIZE.y
		)
		draw_rect(rect, Color(0, 0, 1, 0.3), true)
	
	# Draw attack range
	for cell in attack_tiles:
		var worldPos = grid_to_world(cell)
		var rect = Rect2(
			worldPos.x,
			worldPos.y,
			CELL_SIZE.x,
			CELL_SIZE.y
		)
		draw_rect(rect, Color(1, 0, 0, 0.3), true)

# Add handler for unit movement
func _on_unit_moved(_unit: GameUnit, _from_pos: Vector2i, _to_pos: Vector2i) -> void:
	# Reinitialize AStar when any unit moves to update valid paths
	initialize_astar()
