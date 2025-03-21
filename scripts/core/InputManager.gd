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
@onready var battle_ui_container: BattleUIContainer = $"../UIManager/BattleUIContainer"
@onready var battle_manager: BattleManager = $"../BattleManager"
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
	unit_manager.unit_moved.connect(_on_unit_moved)
	battle_ui_container.action_menu.action_selected.connect(_on_action_selected)
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
			_handle_action_selection(event)
			_handle_cancel(event)
		InputState.TARGET_SELECTION:
			_handle_target_selection(event)
			_handle_cancel(event)
		InputState.MENU_OPEN:
			# Menu input is handled by UI
			_handle_cancel(event)

func change_state(new_state: int) -> void:
	current_state = new_state
	
	match new_state:
		InputState.GRID_SELECTION:
			grid_system.clear_highlights()
			battle_ui_container.action_menu.hide()
			_update_hover_ui()
		InputState.MOVEMENT_SELECTION:
			battle_ui_container.unit_overview_ui.hide_unit_stats()
			battle_ui_container.action_menu.hide()
			_update_hover_ui()
		InputState.ACTION_SELECTION:
			battle_ui_container.unit_overview_ui.hide_unit_stats()
			battle_ui_container.action_menu.show_actions(unit_manager.selected_unit.get_available_actions())
		InputState.TARGET_SELECTION:
			_on_cursor_move_request(valid_targets[0])
			battle_ui_container.action_menu.hide()
			_update_hover_ui()
			grid_system.highlight_attack_range(valid_targets)


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

func _handle_action_selection(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		battle_ui_container.action_menu.select_next_action()
	elif event.is_action_pressed("ui_up"):
		battle_ui_container.action_menu.select_previous_action()
	elif event.is_action_pressed("ui_accept"):
		battle_ui_container.action_menu.confirm_selection()
	else:
		return

func _on_cursor_move_request(grid_position: Vector2i) -> void:
	if grid_system.is_within_grid(grid_position):
		cursor_position = grid_position
		cursor_move_request.emit(cursor_position)
		_update_hover_ui()
		
func _on_unit_moved(unit: GameUnit, _from: Vector2i, _to:Vector2i) -> void:
	if unit.can_act:
		change_state(InputState.ACTION_SELECTION)
	else:
		unit_manager.deselect_unit()
		change_state(InputState.GRID_SELECTION)

func _update_hover_ui() -> void:
	var unit = unit_manager.get_unit_at(cursor_position)
	if unit:
		var is_player = unit.faction == GameUnit.Faction.PLAYER
		battle_ui_container.unit_overview_ui.show_unit_stats(unit, is_player)
	else:
		battle_ui_container.unit_overview_ui.hide_unit_stats()

func _handle_selection(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		tile_selected.emit(cursor_position)
		
		var unit = unit_manager.get_unit_at(cursor_position)
		
		if unit:
			if unit.faction == GameUnit.Faction.PLAYER and unit.can_move:
				unit_manager.select_unit(unit)
				change_state(InputState.MOVEMENT_SELECTION)
				# Hide unit stats UI when selecting a unit
				battle_ui_container.unit_overview_ui.hide_unit_stats()

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
				# Lock UI while moving
				change_state(InputState.LOCKED)
				unit_manager.move_unit(selected_unit, cursor_position)
			else:
				# Invalid movement position
				# Could play a sound or show a message
				pass

func _handle_target_selection(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_move_to_nearest_target(Vector2i(0, 1))
	elif event.is_action_pressed("ui_up"):
		_move_to_nearest_target(Vector2i(0, -1))
	elif event.is_action_pressed("ui_left"):
		_move_to_nearest_target(Vector2i(-1, 0))
	elif event.is_action_pressed("ui_right"):
		_move_to_nearest_target(Vector2i(1, 0))
	elif event.is_action_pressed("ui_accept"):
		var selected_unit = unit_manager.selected_unit
		
		if selected_unit and cursor_position in valid_targets:
			var target_unit = unit_manager.get_unit_at(cursor_position)
			
			if target_unit:
				match action_type:
					"attack":
						await battle_manager.execute_combat(selected_unit, target_unit)
						unit_manager.end_unit_turn(selected_unit)
					# Other action types can be added here like Trade or Heal
			
			# Reset target selection
			valid_targets.clear()
			action_type = ""
			change_state(InputState.GRID_SELECTION)

	else:
		return

func _handle_cancel(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match current_state:
			InputState.MOVEMENT_SELECTION:
				unit_manager.deselect_unit()
				battle_ui_container.unit_overview_ui.hide_unit_stats()
				change_state(InputState.GRID_SELECTION)
			InputState.ACTION_SELECTION:
				unit_manager.revert_unit_movement(unit_manager.selected_unit)
				await get_tree().process_frame 
				change_state(InputState.MOVEMENT_SELECTION)
			InputState.TARGET_SELECTION:
				unit_manager.highlight_unit_attack_range(unit_manager.selected_unit)
				valid_targets.clear()
				action_type = ""
				_on_cursor_move_request(unit_manager.selected_unit.grid_position)
				change_state(InputState.ACTION_SELECTION)
			InputState.MENU_OPEN:
				# TODO Close menu
				change_state(InputState.GRID_SELECTION)
		
		action_canceled.emit()

func _on_game_state_changed(new_state: int) -> void:
	match new_state:
		GameManager.GameState.PLAYER_TURN:
			change_state(InputState.GRID_SELECTION)
		_:
			change_state(InputState.LOCKED)
	unit_manager.deselect_unit()

func _on_action_selected(action_id: String) -> void:
	var selected_unit = unit_manager.selected_unit
	if not selected_unit:
		return
	
	# TODO: This could be moved to a separate class like an Action class?
	match action_id:
		"attack":
			# Set up attack targeting
			var attack_range = grid_system.calculate_attack_range(
				[selected_unit.grid_position],
				selected_unit.min_attack_range,
				selected_unit.attack_range
			)
			valid_targets = attack_range.filter(func(pos): return unit_manager.has_unit_at(pos))
			if valid_targets.size() <= 0:
				# TODO Attack action should be disabled if no valid targets are found
				print("NO VALID TARGETS")
				unit_manager.end_unit_turn(selected_unit)
				change_state(InputState.GRID_SELECTION)
				return
			action_type = "attack"
			change_state(InputState.TARGET_SELECTION)
		"wait":
			# End unit's turn
			unit_manager.end_unit_turn(selected_unit)
			change_state(InputState.GRID_SELECTION)

func _move_to_nearest_target(direction: Vector2i) -> void:
	if valid_targets.is_empty():
		return
		
	# First try to find targets in the pressed direction
	var current_pos = cursor_position
	var targets_in_direction = valid_targets.filter(func(pos): 
		var diff = pos - current_pos
		return sign(diff.x) == sign(direction.x) and sign(diff.y) == sign(direction.y)
	)
	
	var closest
	# If we found targets in that direction, move to the closest one
	if not targets_in_direction.is_empty():
		closest = targets_in_direction[0]
		var closest_distance = current_pos.distance_squared_to(closest)
		
		for target in targets_in_direction:
			var dist = current_pos.distance_squared_to(target)
			if dist < closest_distance:
				closest = target
				closest_distance = dist
		
	else:
		# If no targets in that direction, move to the overall closest target
		closest = valid_targets[0]
		var closest_distance = current_pos.distance_squared_to(closest)
		
		for target in valid_targets:
			var dist = current_pos.distance_squared_to(target)
			if dist < closest_distance:
				closest = target
				closest_distance = dist
		
	_on_cursor_move_request(closest)
	_update_hover_ui()
