extends Node2D

class_name UnitManager

# Lists of units by faction
var player_units: Array = []
var enemy_units: Array = []
var ally_units: Array = []  # NPCs that are friendly but not player-controlled

var selected_unit: Unit = null
var active_unit: Unit = null

@onready var grid_system: GridSystem = $"../GridSystem"

# Signals
signal unit_selected(unit: Unit)
signal unit_deselected()
signal unit_moved(unit: Unit, from_pos: Vector2i, to_pos: Vector2i)
signal unit_action_completed(unit: Unit)
signal unit_defeated(unit: Unit)

func reset() -> void:
	player_units.clear()
	enemy_units.clear()
	ally_units.clear()
	
	selected_unit = null
	active_unit = null

func add_unit(unit: Unit) -> void:
	match unit.faction:
		Unit.Faction.PLAYER:
			player_units.append(unit)
		Unit.Faction.ENEMY:
			enemy_units.append(unit)
		Unit.Faction.ALLY:
			ally_units.append(unit)
	
	unit.defeated.connect(_on_unit_defeated)

func remove_unit(unit: Unit) -> void:
	match unit.faction:
		Unit.Faction.PLAYER:
			player_units.erase(unit)
		Unit.Faction.ENEMY:
			enemy_units.erase(unit)
		Unit.Faction.ALLY:
			ally_units.erase(unit)
	
	unit.defeated.disconnect(_on_unit_defeated)

func get_unit_at(grid_pos: Vector2i) -> Unit:
	for unit in player_units + enemy_units + ally_units:
		if unit.grid_position == grid_pos:
			return unit
	return null

func has_unit_at(grid_pos: Vector2i) -> bool:
	return get_unit_at(grid_pos) != null

func select_unit(unit: Unit) -> void:
	if selected_unit == unit:
		return
		
	if selected_unit:
		deselect_unit()
		
	selected_unit = unit
	unit.select()
	
	if unit.can_move:
		var valid_moves = grid_system.calculate_movement_range(
			unit.grid_position, 
			unit.movement
		)
		grid_system.highlight_movement_range(valid_moves)
		
		var valid_attacks = grid_system.calculate_attack_range(
			valid_moves + [unit.grid_position],
			unit.min_attack_range,
			unit.attack_range
		)
		
		# Filter out cells that are in valid_moves
		var attack_only_cells = []
		for cell in valid_attacks:
			if not valid_moves.has(cell) and cell != unit.grid_position:
				attack_only_cells.append(cell)
				
		grid_system.highlight_attack_range(attack_only_cells)
	
	unit_selected.emit(unit)

func deselect_unit() -> void:
	if selected_unit:
		selected_unit.deselect()
		selected_unit = null
		grid_system.clear_highlights()
		unit_deselected.emit()

func move_unit(unit: Unit, target_pos: Vector2i) -> void:
	if not unit.can_move:
		return
	var from_pos = unit.grid_position
	var path = grid_system.find_path(from_pos, target_pos)
	if path.is_empty():
		return
		
	active_unit = unit
	grid_system.clear_highlights()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Set initial state to moving
	unit.set_state(unit.UnitState.IDLE)
	
	# Move along each point in the path
	for i in range(1, path.size()):
		var current_pos = path[i-1]
		var next_pos = path[i]
		var next_world_pos = grid_system.grid_to_world_centered(next_pos)
		
		tween.tween_callback(func():
			if next_pos.x > current_pos.x:
				unit.set_state(unit.UnitState.MOVING_RIGHT)
			elif next_pos.x < current_pos.x:
				unit.set_state(unit.UnitState.MOVING_LEFT)
		)
		tween.tween_property(unit, "position", next_world_pos, 0.3)
	
	# When tween steps are all completed
	tween.finished.connect(func():
		unit.grid_position = target_pos
		if unit.is_selected:
			unit.set_state(unit.UnitState.SELECTED)
		else:
			unit.set_state(unit.UnitState.IDLE)
		
		unit.can_move = false
		
		if unit == selected_unit:
			# Show attack range from new position
			var attack_range = grid_system.calculate_attack_range(
				[unit.grid_position],
				unit.min_attack_range,
				unit.attack_range
			)
			grid_system.highlight_attack_range(attack_range)
		
		unit_moved.emit(unit, from_pos, target_pos)
	)

func end_unit_turn(unit: Unit) -> void:
	unit.can_move = false
	unit.can_act = false
	
	if unit == selected_unit:
		deselect_unit()
		
	active_unit = null
	unit_action_completed.emit(unit)

# Prepare player units for a new turn
func prepare_player_units_for_turn() -> void:
	for unit in player_units:
		unit.can_move = true
		unit.can_act = true

# Prepare enemy units for a new turn
func prepare_enemy_units_for_turn() -> void:
	for unit in enemy_units:
		unit.can_move = true
		unit.can_act = true

# Check if all player units have completed their actions
func are_all_player_units_done() -> bool:
	for unit in player_units:
		if unit.can_move or unit.can_act:
			return false
	return true

# Check if all enemy units have completed their actions
func are_all_enemy_units_done() -> bool:
	for unit in enemy_units:
		if unit.can_move or unit.can_act:
			return false
	return true

# Check if all units of a faction are defeated
func is_faction_defeated(faction: int) -> bool:
	match faction:
		Unit.Faction.PLAYER:
			return player_units.is_empty()
		Unit.Faction.ENEMY:
			return enemy_units.is_empty()
		Unit.Faction.ALLY:
			return ally_units.is_empty()
	return false

# Handle unit defeat
func _on_unit_defeated(unit: Unit) -> void:
	# Emit signal first before removing
	unit_defeated.emit(unit)
	
	# Remove unit from the game
	remove_unit(unit)
	
	# Check for victory/defeat conditions
	if is_faction_defeated(Unit.Faction.PLAYER):
		get_parent().change_state(get_parent().GameState.GAME_OVER)
	elif is_faction_defeated(Unit.Faction.ENEMY):
		get_parent().change_state(get_parent().GameState.VICTORY) 
