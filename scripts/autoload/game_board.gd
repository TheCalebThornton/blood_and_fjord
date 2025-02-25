extends Node

# Grid size in pixels
const CELL_SIZE: int = 64

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(world_pos.x / CELL_SIZE),
		floor(world_pos.y / CELL_SIZE)
	)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * CELL_SIZE + CELL_SIZE / 2,
		grid_pos.y * CELL_SIZE + CELL_SIZE / 2
	) 

func get_current_map_size() -> Vector2i:
	var battleMap: BattleMap = get_tree().current_scene.get_node("BattleMap")
	if battleMap:
		return battleMap.grid_size
	return Vector2i.ZERO
