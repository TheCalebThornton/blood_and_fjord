extends Node

# Grid size in pixels
const CELL_SIZE = 64

# Convert world position to grid position
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(world_pos.x / CELL_SIZE),
		floor(world_pos.y / CELL_SIZE)
	)

# Convert grid position to world position
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * CELL_SIZE + CELL_SIZE / 2,
		grid_pos.y * CELL_SIZE + CELL_SIZE / 2
	) 
