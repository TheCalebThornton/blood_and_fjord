extends Node2D
class_name BattleMap

@onready var tile_layer: TileMapLayer = $TileMapLayer
@onready var player_start_positions: TileMapLayer = $PlayerPositions
@onready var enemy_start_positions: TileMapLayer = $EnemyPositions
#@onready var turn_manager: TurnManager = $EnemyPositions
@export var grid_color: Color = Color(0.5, 0.5, 0.5, 0.3)

var grid_size: Vector2i:
	get:
		return tile_layer.get_used_rect().size
var selected_character: Character = null
var characters: Array[Character] = []
var players: Array[Character] = []
var enemies: Array[Character] = []
var selected_valid_moves: Array[Vector2i] = []
var movement_manager: MovementManager
var turn_manager: TurnManager

const MOVE_INDICATOR_COLOR = Color(0.2, 1.0, 0.2, 0.3)
const MOVE_INDICATOR_BORDER_COLOR = Color(0.2, 1.0, 0.2, 0.8)

func _ready():
	for child in get_children():
		if child is Character:
			characters.append(child)
	movement_manager = MovementManager.new(grid_size, characters)
	turn_manager = TurnManager.new(characters)
	turn_manager.turn_changed.connect(_on_turn_changed)
	
	for c in characters:
		var startPositions = null
		if c.stats.faction != null && c.stats.faction.value == Faction.FactionEnum.PLAYER:
			startPositions = player_start_positions.get_used_cells()
			players.append(c)
		elif c.stats.faction != null && c.stats.faction.value == Faction.FactionEnum.ENEMY:
			startPositions = enemy_start_positions.get_used_cells()
			enemies.append(c)
		else:
			# fallback for now; eventually need to account for 'Other'
			startPositions = enemy_start_positions.get_used_cells()
			enemies.append(c)
		movement_manager.spawn_character(c, startPositions)

	turn_manager.start_game()

func _unhandled_input(event):
	if event.is_action_pressed("primary_interaction"):
		var grid_pos = GameBoard.world_to_grid(get_global_mouse_position())
		handle_grid_click(grid_pos)

func handle_grid_click(grid_pos: Vector2i):
	var action_panel: CharacterActionsPanel = get_node("CharacterActionsPanel")
	if action_panel and action_panel.is_open or \
		# TODO Need to handle 'character acting' somehow. Maybe best to use a UI Manager?
		selected_character and selected_character.actions.is_acting():
			# Short circuit while busy
			pass

	var charAt = movement_manager.get_character_at(grid_pos)
	if selected_character:
		if selected_valid_moves.has(grid_pos) and selected_character.actions.can_move:
			# Move character
			selected_character.move_to(grid_pos)
			undraw_valid_moves()
		elif charAt == selected_character:
			deselect_character()
		elif charAt:
			# Swap selected character
			# TODO QoL, if opposing faction and in move range, attack
			deselect_character()
			select_character(charAt)
	else:
		# Try to select a character at the clicked position
		if charAt and turn_manager.is_characters_turn(charAt) and charAt.actions.can_move:
			select_character(charAt)

func select_character(character: Character):
	if selected_character:
		deselect_character()
	selected_character = character
	selected_character.select()
	selected_valid_moves = movement_manager.get_valid_moves(selected_character)
	queue_redraw()

func deselect_character():
	selected_character.deselect()
	selected_character = null
	undraw_valid_moves()

func undraw_valid_moves():
	selected_valid_moves = []
	queue_redraw()

func draw_grid():
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var world_pos = GameBoard.grid_to_world(Vector2i(x, y))
			var rect_pos = world_pos - Vector2(GameBoard.CELL_SIZE/2, GameBoard.CELL_SIZE/2)
			var rect_size = Vector2(GameBoard.CELL_SIZE, GameBoard.CELL_SIZE)
			draw_rect(Rect2(rect_pos, rect_size), grid_color, false)

func _draw():
	draw_grid()
	# Draw move indicators
	for pos in selected_valid_moves:
		var world_pos = GameBoard.grid_to_world(pos)
		var rect_pos = world_pos - Vector2(GameBoard.CELL_SIZE/2, GameBoard.CELL_SIZE/2)
		var rect_size = Vector2(GameBoard.CELL_SIZE, GameBoard.CELL_SIZE)
		draw_rect(Rect2(rect_pos, rect_size), MOVE_INDICATOR_COLOR)
		draw_rect(Rect2(rect_pos, rect_size), MOVE_INDICATOR_BORDER_COLOR, false)

func _on_turn_changed(faction: Faction):
	print("Turn changed to: ", faction.get_faction_name())
	# Optionally add UI updates here
