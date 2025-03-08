extends Node2D
class_name GridCursor

var current_position: Vector2i = Vector2i(0, 0)
var target_position: Vector2 = Vector2(0, 0)
var move_speed: float = 10.0

var grid_system: GridSystem
var input_manager: InputManager

var cursor_color: Color = Color(1, 1, 0, 0.5)  # Yellow semi-transparent
var cursor_size: Vector2 = Vector2(64, 64)

# Add this at the top of the class, after class_name GridCursor
signal cursor_moved(grid_pos)

func _ready():
	grid_system = get_node("/root/Main/GameManager/GridSystem")
	input_manager = get_node("/root/Main/GameManager/InputManager")
	cursor_size = grid_system.CELL_SIZE

	input_manager.cursor_move_request.connect(_on_cursor_move_requested)
	
	# Set initial position
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
	# Draw cursor rectangle
	var rect = Rect2(-cursor_size.x / 2, -cursor_size.y / 2, cursor_size.x, cursor_size.y)
	draw_rect(rect, cursor_color, false, 3.0)  # 3.0 is border width
	
	# Draw diagonal lines for better visibility
	#draw_line(Vector2(-cursor_size.x / 2, -cursor_size.y / 2), 
			  #Vector2(cursor_size.x / 2, cursor_size.y / 2), 
			  #cursor_color, 2.0)
	#
	#draw_line(Vector2(cursor_size.x / 2, -cursor_size.y / 2), 
			  #Vector2(-cursor_size.x / 2, cursor_size.y / 2), 
			  #cursor_color, 2.0)

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
