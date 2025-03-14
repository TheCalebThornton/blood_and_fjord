extends Node2D

class_name InputManager

enum InputState {
	GRID_SELECTION,
	MOVEMENT_SELECTION,
	ACTION_SELECTION,
	TARGET_SELECTION,
	MENU_OPEN,
	LOCKED
}

var current_state: int = InputState.GRID_SELECTION

var game_manager: GameManager
@onready var grid_system: GridSystem = $"../GridSystem"
@onready var unit_manager: UnitManager = $"../UnitManager"
@onready var unit_overview_ui: UnitOverviewUI = $"../UIManager/UnitOverviewUI"

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
	unit_manager.cursor_move_request.connect(_on_cursor_move_request)
	# Initialize UI based on cursor position
	call_deferred("_update_hover_ui")

func _unhandled_input(event: InputEvent) -> void:
	# Only process input during player turn
	if game_manager.current_state != GameManager.GameState.PLAYER_TURN:
		return
	
	match current_state:
		InputState.GRID_SELECTION:
			_handle_cursor_movement(event)
			_handle_selection(event)
			_handle_cancel(event)
		InputState.MOVEMENT_SELECTION:
			_handle_cursor_movement(event)
			_handle_movement_selection(event)
			_handle_cancel(event)
		InputState.ACTION_SELECTION:
			# TODO add Action UI selection handler
			#_handle_cursor_movement(event)
			_handle_cancel(event)
		InputState.TARGET_SELECTION:
			_handle_cursor_movement(event)
			_handle_target_selection(event)
			_handle_cancel(event)
		InputState.MENU_OPEN:
			# Menu input is handled by UI
			_handle_cancel(event)

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
			_update_hover_ui()

func _on_cursor_move_request(grid_position: Vector2i) -> void:
	if grid_system.is_within_grid(grid_position):
		cursor_position = grid_position
		cursor_move_request.emit(cursor_position)
		_update_hover_ui()

func _update_hover_ui() -> void:
	var unit = unit_manager.get_unit_at(cursor_position)
	
	if unit:
		var is_player = unit.faction == GameUnit.Faction.PLAYER
		unit_overview_ui.show_unit_stats(unit, is_player)
	else:
		unit_overview_ui.hide_unit_stats()

func _handle_selection(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		tile_selected.emit(cursor_position)
		
		var unit = unit_manager.get_unit_at(cursor_position)
		
		if unit:
			if unit.faction == GameUnit.Faction.PLAYER and unit.can_move:
				unit_manager.select_unit(unit)
				change_state(InputState.MOVEMENT_SELECTION)
				# Hide unit stats UI when selecting a unit
				unit_overview_ui.hide_unit_stats()

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
					change_state(InputState.ACTION_SELECTION)
				else:
					unit_manager.deselect_unit()
					change_state(InputState.GRID_SELECTION)
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
						game_manager.battle_manager.execute_combat(selected_unit, target_unit)
						unit_manager.end_unit_turn(selected_unit)
						
						# Reset state
						valid_targets.clear()
						action_type = ""
						change_state(InputState.GRID_SELECTION)
					# Other action types can be added here
			
			# Reset target selection
			valid_targets.clear()
			action_type = ""

func _handle_cancel(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match current_state:
			InputState.MOVEMENT_SELECTION:
				unit_manager.deselect_unit()
				unit_overview_ui.hide_unit_stats()
				change_state(InputState.GRID_SELECTION)
			InputState.ACTION_SELECTION:
				if unit_manager.selected_unit:
					unit_manager.revert_unit_movement(unit_manager.selected_unit)
				change_state(InputState.MOVEMENT_SELECTION)
			InputState.TARGET_SELECTION:
				# Cancel target selection
				valid_targets.clear()
				action_type = ""
				change_state(InputState.ACTION_SELECTION)
			InputState.MENU_OPEN:
				# Close menu
				change_state(InputState.GRID_SELECTION)
		
		action_canceled.emit()

func _try_attack(attacker: GameUnit, defender: GameUnit) -> void:
	var attack_range = grid_system.calculate_attack_range(
		[attacker.grid_position],
		attacker.min_attack_range,
		attacker.attack_range
	)
	
	if defender.grid_position in attack_range:
		game_manager.battle_manager.execute_combat(attacker, defender)
		
		unit_manager.end_unit_turn(attacker)
		
		change_state(InputState.GRID_SELECTION)
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
		InputState.GRID_SELECTION:
			grid_system.clear_highlights()
			_update_hover_ui()
		InputState.MOVEMENT_SELECTION:
			unit_overview_ui.hide_unit_stats()
		InputState.TARGET_SELECTION:
			unit_overview_ui.hide_unit_stats()
			grid_system.highlight_attack_range(valid_targets)

func _on_game_state_changed(new_state: int) -> void:
	match new_state:
		GameManager.GameState.PLAYER_TURN:
			change_state(InputState.GRID_SELECTION)
		_:
			change_state(InputState.LOCKED)
	unit_manager.deselect_unit()
