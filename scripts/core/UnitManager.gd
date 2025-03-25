extends Node2D

class_name UnitManager

# Lists of units by faction
var player_units: Array = []
var enemy_units: Array = []
var ally_units: Array = []  # NPCs that are friendly but not player-controlled

var selected_unit: GameUnit = null

@onready var grid_system: GridSystem = $"../GridSystem"

# Signals
signal unit_selected(unit: GameUnit)
signal unit_deselected()
signal unit_moved(unit: GameUnit, from_pos: Vector2i, to_pos: Vector2i)
signal unit_turn_completed(unit: GameUnit)
signal unit_defeated(unit: GameUnit)
signal cursor_move_request(grid_position: Vector2i)

func reset() -> void:
	player_units.clear()
	enemy_units.clear()
	ally_units.clear()
	
	selected_unit = null

func add_unit(unit: GameUnit) -> void:
	match unit.faction:
		GameUnit.Faction.PLAYER:
			player_units.append(unit)
		GameUnit.Faction.ENEMY:
			enemy_units.append(unit)
		GameUnit.Faction.ALLY:
			ally_units.append(unit)
	
	unit.defeated.connect(_on_unit_defeated)

func remove_unit(unit: GameUnit) -> void:
	match unit.faction:
		GameUnit.Faction.PLAYER:
			player_units.erase(unit)
		GameUnit.Faction.ENEMY:
			enemy_units.erase(unit)
		GameUnit.Faction.ALLY:
			ally_units.erase(unit)
	
	unit.defeated.disconnect(_on_unit_defeated)

func get_unit_at(grid_pos: Vector2i) -> GameUnit:
	for unit in player_units + enemy_units + ally_units:
		if unit.grid_position == grid_pos:
			return unit
	return null

func has_unit_at(grid_pos: Vector2i) -> bool:
	return get_unit_at(grid_pos) != null

func highlight_unit_attack_range(unit: GameUnit) -> void:
	if not unit:
		return

	var attack_range = grid_system.calculate_attack_range(
		[unit.grid_position],
		unit.min_attack_range,
		unit.attack_range)
	grid_system.highlight_attack_range(attack_range)

func select_unit(unit: GameUnit) -> void:
	if selected_unit == unit:
		# TODO Open action menu
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

#region movement:
func move_unit(unit: GameUnit, target_pos: Vector2i, record_move: bool = true) -> void:
	if not unit.can_move:
		return
	
	if record_move:
		unit.original_position = unit.grid_position
		
	var from_pos = unit.grid_position
	var path = grid_system.find_path(from_pos, target_pos)
	if path.is_empty():
		return
		
	grid_system.clear_highlights()
	
	# Convert path positions to world coordinates
	var world_positions = []
	for pos in path:
		world_positions.append(grid_system.grid_to_world_centered(pos))
	
	# Calculate total path length for consistent speed
	var total_distance = 0.0
	for i in range(1, world_positions.size()):
		total_distance += world_positions[i-1].distance_to(world_positions[i])
	
	var tween = create_tween()
	tween.tween_method(
		func(progress: float):
			var current_pos = _get_position_along_path(world_positions, progress)
			unit.position = current_pos
			
			# Update unit facing direction
			if progress < 1.0:  # Don't update direction at the end
				var next_pos = _get_position_along_path(world_positions, min(progress + 0.1, 1.0))
				if next_pos.x > current_pos.x:
					unit.set_state(unit.UnitState.MOVING_RIGHT)
				elif next_pos.x < current_pos.x:
					unit.set_state(unit.UnitState.MOVING_LEFT),
		0.0,
		1.0,
		(total_distance / grid_system.CELL_SIZE.x) / 3 # 3 grids per second movespeed
	)
	
	# When movement is completed
	tween.finished.connect(func():
		unit.grid_position = target_pos
		if unit.is_selected:
			unit.set_state(unit.UnitState.SELECTED)
		else:
			unit.set_state(unit.UnitState.IDLE)
		unit.can_move = false
		unit.has_moved = true
		
		if unit == selected_unit:
			var attack_range = grid_system.calculate_attack_range(
				[unit.grid_position],
				unit.min_attack_range,
				unit.attack_range
			)
			grid_system.highlight_attack_range(attack_range)
		unit_moved.emit(unit, from_pos, target_pos)
	)

func teleport_unit(unit: GameUnit, target_pos: Vector2i, animate: bool = false) -> void:
	if animate:
		# TODO add teleportation effect
		pass
	
	grid_system.clear_highlights()
	unit.position = grid_system.grid_to_world_centered(target_pos)
	unit.grid_position = target_pos
	if unit.is_selected:
		unit.set_state(unit.UnitState.SELECTED)
	else:
		unit.set_state(unit.UnitState.IDLE)

func _get_position_along_path(points: Array, progress: float) -> Vector2:
	if progress <= 0:
		return points[0]
	if progress >= 1:
		return points[-1]
		
	var total_length = 0
	var lengths = []
	
	# Calculate segment lengths
	for i in range(1, points.size()):
		var length = points[i-1].distance_to(points[i])
		total_length += length
		lengths.append(length)
	
	var target_length = total_length * progress
	var current_length = 0
	
	# Find current segment
	for i in range(lengths.size()):
		if current_length + lengths[i] >= target_length:
			var segment_progress = (target_length - current_length) / lengths[i]
			return points[i].lerp(points[i + 1], segment_progress)
		current_length += lengths[i]
	
	return points[-1]

func revert_unit_movement(unit: GameUnit) -> void:
	if unit.has_moved:
		teleport_unit(unit, unit.original_position)
	unit.has_moved = false
	unit.can_move = true
	selected_unit = null
	cursor_move_request.emit(unit.original_position)
	select_unit(unit)
#endregion

func end_unit_turn(unit: GameUnit) -> void:
	# TODO this is overwriting my death animation
	unit.original_position = unit.grid_position
	unit.can_move = false
	unit.can_act = false
	
	if unit == selected_unit:
		deselect_unit()
		
	selected_unit = null
	unit_turn_completed.emit(unit)

func force_faction_end(faction: GameUnit.Faction) -> void:
	for unit in _get_unit_list_for_faction(faction):
		unit.set_state(GameUnit.UnitState.INACTIVE)
		unit.can_move = false
		unit.can_act = false

func prepare_faction_units_for_turn(faction: GameUnit.Faction) -> void:
	for unit in _get_unit_list_for_faction(faction):
		unit.can_move = true
		unit.can_act = true
		unit.set_state(GameUnit.UnitState.IDLE)

func are_all_faction_units_done(faction: GameUnit.Faction) -> bool:
	for unit in _get_unit_list_for_faction(faction):
		if unit.can_move or unit.can_act:
			return false
	return true

func is_faction_defeated(faction: GameUnit.Faction) -> bool:
	match faction:
		GameUnit.Faction.PLAYER:
			return player_units.is_empty()
		GameUnit.Faction.ENEMY:
			return enemy_units.is_empty()
		GameUnit.Faction.ALLY:
			return ally_units.is_empty()
	return false

func _on_unit_defeated(unit: GameUnit) -> void:
	unit_defeated.emit(unit)
	remove_unit(unit)
	
	# Check for victory/defeat conditions
	if is_faction_defeated(GameUnit.Faction.PLAYER):
		get_parent().change_state(get_parent().GameState.GAME_OVER)
	elif is_faction_defeated(GameUnit.Faction.ENEMY):
		get_parent().change_state(get_parent().GameState.VICTORY)
		
func _get_unit_list_for_faction(faction: GameUnit.Faction):
	if faction == GameUnit.Faction.PLAYER:
		return player_units
	elif faction == GameUnit.Faction.ENEMY:
		return enemy_units
	elif faction == GameUnit.Faction.ALLY:
		return ally_units
