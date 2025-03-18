extends Node2D
class_name GridCursor

var current_position: Vector2i = Vector2i(0, 0)
var target_position: Vector2 = Vector2(0, 0)
var move_speed: float = 10.0

var grid_system: GridSystem
var input_manager: InputManager

var cursor_color: Color = Color(255, 255, 255, 0.7)
var cursor_size: Vector2 = Vector2(64, 64)

signal cursor_moved(current_position: Vector2i)

func _ready():
	grid_system = get_node("/root/Main/GameManager/GridSystem")
	input_manager = get_node("/root/Main/GameManager/InputManager")
	cursor_size = grid_system.CELL_SIZE

	input_manager.cursor_move_request.connect(_on_cursor_move_requested)
	
	current_position = Vector2i(0, 0)
	position = grid_system.grid_to_world_centered(current_position)
	target_position = position

func _process(delta):
	# Smoothly move cursor to target position
	if position.distance_to(target_position) > 1.0:
		position = position.lerp(target_position, delta * move_speed)
	else:
		position = target_position

func _draw():
	# Define corner size (how long each line of the L will be)
	var corner_length = cursor_size.x / 4
	var half_width = cursor_size.x / 2
	var half_height = cursor_size.y / 2
	
	# Top-left corner
	draw_line(Vector2(-half_width, -half_height), Vector2(-half_width + corner_length, -half_height), cursor_color, 3.0)
	draw_line(Vector2(-half_width, -half_height), Vector2(-half_width, -half_height + corner_length), cursor_color, 3.0)
	
	# Top-right corner
	draw_line(Vector2(half_width, -half_height), Vector2(half_width - corner_length, -half_height), cursor_color, 3.0)
	draw_line(Vector2(half_width, -half_height), Vector2(half_width, -half_height + corner_length), cursor_color, 3.0)
	
	# Bottom-left corner
	draw_line(Vector2(-half_width, half_height), Vector2(-half_width + corner_length, half_height), cursor_color, 3.0)
	draw_line(Vector2(-half_width, half_height), Vector2(-half_width, half_height - corner_length), cursor_color, 3.0)
	
	# Bottom-right corner
	draw_line(Vector2(half_width, half_height), Vector2(half_width - corner_length, half_height), cursor_color, 3.0)
	draw_line(Vector2(half_width, half_height), Vector2(half_width, half_height - corner_length), cursor_color, 3.0)

func _on_cursor_move_requested(grid_pos: Vector2i):
	current_position = grid_pos
	target_position = grid_system.grid_to_world_centered(grid_pos)
	queue_redraw()
	
	emit_signal("cursor_moved", grid_pos)

func set_grid_position(grid_pos: Vector2i):
	current_position = grid_pos
	position = grid_system.grid_to_world_centered(grid_pos)
	target_position = position
	queue_redraw()

# Flash the cursor (for highlighting)
func flash():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0.2), 0.3)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1.0), 0.3) 
