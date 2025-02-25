extends Camera2D

const SCROLL_SPEED: int = 10000

var is_dragging: bool = false
var drag_start_position: Vector2 = Vector2.ZERO

func _ready():
	setup_camera_limits()
	set_position_value(position) # ensure camera is within limits

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("camera_drag"):
		is_dragging = true
		drag_start_position = event.position
	elif event.is_action_released("camera_drag"):
		is_dragging = false

func _process(delta):
	if is_dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var movement = (drag_start_position - mouse_pos)
		var newPos = position + (movement * delta * SCROLL_SPEED / 100)
		set_position_value(newPos)
		drag_start_position = mouse_pos
		
func set_position_value(newPos):
		var viewport_size = get_viewport_rect().size
		var half_view_width = viewport_size.x / 2
		var half_view_height = (viewport_size.y / 2) - 20 #add margin for window bar

		newPos.x = clampf(newPos.x, half_view_width, limit_right - half_view_width)
		newPos.y = clampf(newPos.y, half_view_height, limit_bottom - half_view_height)
		
		position = newPos

func setup_camera_limits():
	var map_limits = GameBoard.grid_to_world(GameBoard.get_current_map_size())
	limit_right = map_limits.x
	limit_bottom = map_limits.y
	limit_left = 0
	limit_top = 0 
