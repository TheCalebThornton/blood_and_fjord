extends Node2D
class_name BattleMap

@onready var tile_layer: TileMapLayer = $TileMapLayer
@onready var player_start_positions: TileMapLayer = $PlayerPositions
@onready var enemy_start_positions: TileMapLayer = $EnemyPositions
@export var grid_color: Color = Color(0.5, 0.5, 0.5, 0.3)
var grid_size: Vector2i:
	get:
		return tile_layer.get_used_rect().size
var valid_moves: Array[Vector2i] = []
var selected_character: Character = null
var characters: Array[Character] = []

const MOVE_INDICATOR_COLOR = Color(0.2, 1.0, 0.2, 0.3)  # Semi-transparent green
const MOVE_INDICATOR_BORDER_COLOR = Color(0.2, 1.0, 0.2, 0.8)  # More solid green border

func _ready():
	for child in get_children():
		if child is Character:
			characters.append(child)
	

func _unhandled_input(event):
	if event.is_action_pressed("primary_interaction"):
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

func draw_move_indicators():
	for pos in valid_moves:
		var world_pos = GameBoard.grid_to_world(pos)
		var rect_pos = world_pos - Vector2(GameBoard.CELL_SIZE/2, GameBoard.CELL_SIZE/2)
		var rect_size = Vector2(GameBoard.CELL_SIZE, GameBoard.CELL_SIZE)
		
		draw_rect(Rect2(rect_pos, rect_size), MOVE_INDICATOR_COLOR)
		# I don't know if I like this border or not
		#draw_rect(Rect2(rect_pos, rect_size), MOVE_INDICATOR_BORDER_COLOR, false)

func draw_grid():
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var world_pos = GameBoard.grid_to_world(Vector2i(x, y))
			var rect_pos = world_pos - Vector2(GameBoard.CELL_SIZE/2, GameBoard.CELL_SIZE/2)
			var rect_size = Vector2(GameBoard.CELL_SIZE, GameBoard.CELL_SIZE)
			draw_rect(Rect2(rect_pos, rect_size), grid_color, false)

func _draw():
	#If this becomes a performance concern, we can move this to a separate TileMapLayer
	draw_move_indicators()
	draw_grid()
