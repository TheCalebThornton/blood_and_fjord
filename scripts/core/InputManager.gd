extends Node2D

class_name InputManager

enum InputState {
	NORMAL,
	UNIT_SELECTED,
	MOVEMENT_SELECTION,
	TARGET_SELECTION,
	MENU_OPEN
}

var current_state: int = InputState.NORMAL

var game_manager: GameManager
@onready var grid_system: GridSystem = $"../GridSystem"
@onready var unit_manager: UnitManager = $"../UnitManager"
#var battle_ui: BattleUI

var cursor_position: Vector2i = Vector2i(0, 0)

# For target selection
var valid_targets: Array = []
var action_type: String = ""

signal cursor_move_request(grid_pos: Vector2i)
signal tile_selected(grid_pos: Vector2i)
signal action_canceled()

func _ready():
	game_manager = get_parent()
	
	game_manager.state_changed.connect(_on_game_state_changed)

func _unhandled_input(event: InputEvent) -> void:
	# Only process input during player turn
	if game_manager.current_state != GameManager.GameState.PLAYER_TURN:
		return
	
	match current_state:
		InputState.NORMAL:
			_handle_cursor_movement(event)
			_handle_selection(event)
			_handle_cancel(event)
		InputState.MOVEMENT_SELECTION:
			_handle_cursor_movement(event)
			_handle_movement_selection(event)
			_handle_cancel(event)
		InputState.TARGET_SELECTION:
			_handle_cursor_movement(event)
			_handle_target_selection(event)
			_handle_cancel(event)
		InputState.MENU_OPEN:
			# Menu input is handled by UI
			_handle_cancel(event)

# Handle cursor movement
func _handle_cursor_movement(event: InputEvent) -> void:
	var movement = Vector2i(0, 0)
	
	if event.is_action_pressed("ui_right"):
		movement.x = 1
	elif event.is_action_pressed("ui_left"):
		movement.x = -1
	elif event.is_action_pressed("ui_down"):
		movement.y = 1
	elif event.is_action_pressed("ui_up"):
		movement.y = -1
	else:
		return
	
	if movement != Vector2i(0, 0):
		var new_pos = cursor_position + movement
		
		if grid_system.is_within_grid(new_pos):
			cursor_position = new_pos
			cursor_move_request.emit(cursor_position)

func _handle_selection(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		tile_selected.emit(cursor_position)
		
		# Check if there's a unit at the cursor position
		var unit = unit_manager.get_unit_at(cursor_position)
		
		if unit:
			if unit.faction == Unit.Faction.PLAYER and unit.can_move:
				unit_manager.select_unit(unit)
				change_state(InputState.MOVEMENT_SELECTION)

func _handle_movement_selection(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var selected_unit = unit_manager.selected_unit
		
		if selected_unit:
			# Check if the position is in movement range
			var movement_range = grid_system.calculate_movement_range(
				selected_unit.grid_position,
				selected_unit.movement
			)
			
			if cursor_position in movement_range and not unit_manager.has_unit_at(cursor_position):
				unit_manager.move_unit(selected_unit, cursor_position)
				
				if selected_unit.can_act:
					change_state(InputState.UNIT_SELECTED)
				else:
					unit_manager.deselect_unit()
					change_state(InputState.NORMAL)
			else:
				# Invalid movement position
				# Could play a sound or show a message
				pass

func _handle_target_selection(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var selected_unit = unit_manager.selected_unit
		
		if selected_unit and cursor_position in valid_targets:
			var target_unit = unit_manager.get_unit_at(cursor_position)
			
			if target_unit:
				match action_type:
					"attack":
						# Execute attack
						game_manager.battle_manager.execute_combat(selected_unit, target_unit)
						
						# End unit's turn
						unit_manager.end_unit_turn(selected_unit)
						
						# Reset state
						valid_targets.clear()
						action_type = ""
						change_state(InputState.NORMAL)
					# Other action types can be added here
			
			# Reset target selection
			valid_targets.clear()
			action_type = ""

func _handle_cancel(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match current_state:
			InputState.UNIT_SELECTED, InputState.MOVEMENT_SELECTION:
				unit_manager.deselect_unit()
				change_state(InputState.NORMAL)
			InputState.TARGET_SELECTION:
				# Cancel target selection
				valid_targets.clear()
				action_type = ""
				change_state(InputState.UNIT_SELECTED)
			InputState.MENU_OPEN:
				# Close menu
				change_state(InputState.UNIT_SELECTED)
		
		action_canceled.emit()

func _try_attack(attacker: Unit, defender: Unit) -> void:
	var attack_range = grid_system.calculate_attack_range(
		[attacker.grid_position],
		attacker.min_attack_range,
		attacker.attack_range
	)
	
	if defender.grid_position in attack_range:
		game_manager.battle_manager.execute_combat(attacker, defender)
		
		unit_manager.end_unit_turn(attacker)
		
		change_state(InputState.NORMAL)
	else:
		# Target not in range, show attack range and enter target selection
		valid_targets = attack_range
		action_type = "attack"
		change_state(InputState.TARGET_SELECTION)
		
		# Highlight valid targets
		grid_system.highlight_attack_range(valid_targets)

func change_state(new_state: int) -> void:
	current_state = new_state
	
	match new_state:
		InputState.NORMAL:
			grid_system.clear_highlights()
		InputState.TARGET_SELECTION:
			grid_system.highlight_attack_range(valid_targets)

func _on_game_state_changed(new_state: int) -> void:
	match new_state:
		GameManager.GameState.PLAYER_TURN:
			# Reset to normal input state at start of player turn
			change_state(InputState.NORMAL)
		_:
			# Disable input for other game states
			change_state(InputState.NORMAL)
			unit_manager.deselect_unit() 
