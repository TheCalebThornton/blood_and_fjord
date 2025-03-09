extends Camera2D

const SCROLL_SPEED: int = 10000
const CAMERA_MARGIN: float = 200.0  # Distance from edge to trigger camera movement
const MIN_ZOOM: float = 0.5  # Minimum zoom level (zoomed out)
const MAX_ZOOM: float = 2.0  # Maximum zoom level (zoomed in)
const DEFAULT_ZOOM: float = 1.0  # Default zoom level

var is_dragging: bool = false
var drag_start_position: Vector2 = Vector2.ZERO

@onready var grid_system: GridSystem = $"/root/Main/GameManager/GridSystem"
@onready var grid_cursor: GridCursor = $"/root/Main/Cursor"  # Adjust path if needed

func _ready():
	setup_camera_limits()
	set_position_value(position) # ensure camera is within limits
	
	# Connect to the cursor's movement signal
	if grid_cursor:
		grid_cursor.connect("cursor_moved", _on_cursor_moved)
		
func set_position_value(newPos):
	var viewport_size = get_viewport_rect().size
	var half_view_width = viewport_size.x / 2
	var half_view_height = (viewport_size.y / 2) - 20 #add margin for window bar

	newPos.x = clampf(newPos.x, half_view_width, limit_right - half_view_width)
	newPos.y = clampf(newPos.y, half_view_height, limit_bottom - half_view_height)
	
	position = newPos

func setup_camera_limits():
	var map_limits = grid_system.grid_to_world(grid_system.grid_size)
	limit_right = map_limits.x
	limit_bottom = map_limits.y
	limit_left = 0
	limit_top = 0

# Called when the cursor moves
func _on_cursor_moved(grid_pos: Vector2i):
	check_cursor_bounds(grid_pos)

func check_cursor_bounds(cursor_position: Vector2):
	var world_cursor_pos = grid_system.grid_to_world(cursor_position)
	var viewport_size = get_viewport_rect().size
	var half_viewport = viewport_size / 2 / zoom.x
	
	var left_edge = position.x - half_viewport.x + CAMERA_MARGIN
	var right_edge = position.x + half_viewport.x - CAMERA_MARGIN
	var top_edge = position.y - half_viewport.y + CAMERA_MARGIN
	var bottom_edge = position.y + half_viewport.y - CAMERA_MARGIN
	
	var camera_move = Vector2.ZERO
	var move_speed = 1.0  # Direct movement factor
	
	# Check if cursor is outside bounds and calculate movement
	if world_cursor_pos.x < left_edge:
		camera_move.x = (world_cursor_pos.x - left_edge) * move_speed
	elif world_cursor_pos.x > right_edge:
		camera_move.x = (world_cursor_pos.x - right_edge) * move_speed
	
	if world_cursor_pos.y < top_edge:
		camera_move.y = (world_cursor_pos.y - top_edge) * move_speed
	elif world_cursor_pos.y > bottom_edge:
		camera_move.y = (world_cursor_pos.y - bottom_edge) * move_speed
	
	if camera_move != Vector2.ZERO:
		# Optional: Add smooth camera movement with a tween
		var tween = create_tween()
		tween.tween_property(self, "position", position + camera_move, 0.2)
		tween.tween_callback(func(): set_position_value(position)) 
