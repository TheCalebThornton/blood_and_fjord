extends Node2D
class_name BattleMap

@onready var tile_layer: TileMapLayer = $TileMapLayer
var grid_size: Vector2i = Vector2i(10,4)
var valid_moves: Array[Vector2i] = []
var selected_character: Character = null
var characters: Array[Character] = []

const MOVE_INDICATOR_COLOR = Color(0.2, 1.0, 0.2, 0.3)  # Semi-transparent green
const MOVE_INDICATOR_BORDER_COLOR = Color(0.2, 1.0, 0.2, 0.8)  # More solid green border
const CELL_SIZE = 64  # Make sure this matches your GameBoard.CELL_SIZE

func _ready():
	for child in get_children():
		if child is Character:
			characters.append(child)

func create_debug_grid(width: int, height: int):
	# Assuming you have a tileset with at least one tile (index 0)
	for x in range(width):
		for y in range(height):
			# Alternate between two tiles for a checkerboard pattern
			var tile_index = 0 if (x + y) % 2 == 0 else 1
			tile_layer.set_cell(Vector2i(x, y), 0, Vector2i(tile_index, 0))

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var grid_pos = world_to_grid(get_global_mouse_position())
		handle_grid_click(grid_pos)

func handle_grid_click(grid_pos: Vector2i):
	
	if selected_character:
		# If a character is selected, try to move them
		if is_valid_move(grid_pos):
			selected_character.move_to(grid_pos)
			deselect_character()
	else:
		# Try to select a character at the clicked position
		var character = get_character_at(grid_pos)
		if character:
			select_character(character)

func select_character(character: Character):
	if selected_character:
		deselect_character()
	selected_character = character
	selected_character.selected = true
	valid_moves = character.get_valid_move_positions()
	valid_moves = valid_moves.filter(func(pos): return is_valid_move(pos))
	queue_redraw()

func deselect_character():
	if selected_character:
		selected_character.selected = false
	selected_character = null
	valid_moves.clear()
	queue_redraw()

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return tile_layer.local_to_map(to_local(world_pos))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return to_global(tile_layer.map_to_local(grid_pos))

func get_character_at(grid_pos: Vector2i) -> Character:
	for character in characters:
		if world_to_grid(character.global_position) == grid_pos:
			return character
	return null

func is_valid_move(pos: Vector2i) -> bool:
	# Check if position is within grid bounds
	if pos.x < 0 or pos.y < 0 or pos.x >= grid_size.x or pos.y >= grid_size.y:
		return false
	if not valid_moves.has(pos):
		return false
	
	# Add any additional move validation here (e.g., checking for obstacles)
	return true

func _draw():
	for pos in valid_moves:
		var world_pos = GameBoard.grid_to_world(pos)
		
		# Create rectangle centered on the cell
		var rect_pos = world_pos - Vector2(CELL_SIZE/2, CELL_SIZE/2)
		var rect_size = Vector2(CELL_SIZE, CELL_SIZE)
		
		# Draw filled square
		draw_rect(Rect2(rect_pos, rect_size), MOVE_INDICATOR_COLOR)
		
		# Draw border, false = unfilled
		draw_rect(Rect2(rect_pos, rect_size), MOVE_INDICATOR_BORDER_COLOR, false) 
