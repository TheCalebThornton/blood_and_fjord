extends Node2D
class_name Character

@export var stats: CharacterStats
@export var grid_position: Vector2i = Vector2i(0,0)
var selected: bool = false:
	set(value):
		selected = value
		modulate = Color(1.4, 1.4, 1.4) if value else Color(1, 1, 1)

func _ready():
	position = GameBoard.grid_to_world(grid_position)
	stats.movement = 3

func move_to(new_grid_pos: Vector2i, animate: bool = true):
	grid_position = new_grid_pos
	var target_pos = GameBoard.grid_to_world(new_grid_pos)
	
	if animate == true:
		create_tween().tween_property(self, "position", target_pos, 0.3)
	else:
		position = target_pos


func get_valid_move_positions() -> Array[Vector2i]:
	var valid_positions: Array[Vector2i] = []
	var movement_range = stats.movement
	
	# Check all positions within movement range
	for x in range(-movement_range, movement_range + 1):
		for y in range(-movement_range, movement_range + 1):
			var check_pos = grid_position + Vector2i(x, y)
			# Manhattan distance for movement (diamond grid)
			if abs(x) + abs(y) <= movement_range:
				valid_positions.append(check_pos)
	
	return valid_positions 

func _mouse_enter():
	if not selected:
		modulate = Color(1.2, 1.2, 1.2)  # Slight highlight

func _mouse_exit():
	if not selected:
		modulate = Color(1, 1, 1)  # Return to normal
