extends Node2D

class_name BattleManager

# Combat-related constants
const MIN_HIT_CHANCE = 0.1  # 10% minimum hit chance
const MAX_HIT_CHANCE = 1.0  # 100% maximum hit chance
const CRITICAL_MULTIPLIER = 1.5  # Critical hits do 50% more damage

# Signals
signal combat_started(attacker: Unit, defender: Unit)
signal combat_ended(attacker: Unit, defender: Unit, defeated: bool)
signal unit_damaged(unit: Unit, damage: int)
signal unit_healed(unit: Unit, amount: int)

# Reference to other systems
@onready var grid_system: GridSystem = $"../GridSystem"
@onready var unit_manager: UnitManager = $"../UnitManager"

# Reset battle state for a new map
func reset() -> void:
	# Reset any battle-specific state
	pass

# Calculate if an attack hits based on accuracy and evasion
func calculate_hit(attacker: Unit, defender: Unit) -> bool:
	var hit_chance = calculate_hit_chance(attacker, defender)
	return randf() <= hit_chance

# Calculate hit chance based on unit stats
func calculate_hit_chance(attacker: Unit, defender: Unit) -> float:
	var base_hit_chance = attacker.accuracy / 100.0
	var evasion_modifier = defender.evasion / 100.0
	
	var final_hit_chance = base_hit_chance * (1.0 - evasion_modifier)
	
	# Clamp between min and max values
	return clampf(final_hit_chance, MIN_HIT_CHANCE, MAX_HIT_CHANCE)

# Calculate if an attack is critical
func calculate_critical(attacker: Unit, defender: Unit) -> bool:
	var crit_chance = attacker.critical / 100.0
	return randf() <= crit_chance

# Calculate damage for an attack
func calculate_damage(attacker: Unit, defender: Unit, is_critical: bool = false) -> int:
	var base_damage = attacker.attack - defender.defense
	
	# Ensure minimum damage of 1
	base_damage = max(1, base_damage)
	
	# Apply critical multiplier if applicable
	if is_critical:
		base_damage = int(base_damage * CRITICAL_MULTIPLIER)
	
	# Apply weapon type effectiveness (can be expanded later)
	# TODO: Implement weapon triangle and effectiveness
	
	return base_damage

# Execute a combat sequence between two units
func execute_combat(attacker: Unit, defender: Unit) -> void:
	# Signal that combat has started
	combat_started.emit(attacker, defender)
	
	# First attack
	process_attack(attacker, defender)
	
	# Check if defender is defeated
	if defender.health <= 0:
		combat_ended.emit(attacker, defender, true)
		return
	
	# Counter-attack if in range and defender can counter
	if can_counter_attack(attacker, defender):
		process_attack(defender, attacker)
		
		# Check if attacker is defeated
		if attacker.health <= 0:
			combat_ended.emit(defender, attacker, true)
			return
	
	# Follow-up attack if attacker is much faster
	if can_follow_up(attacker, defender):
		process_attack(attacker, defender)
		
		# Check if defender is defeated
		if defender.health <= 0:
			combat_ended.emit(attacker, defender, true)
			return
	
	# Signal that combat has ended with no defeats
	combat_ended.emit(attacker, defender, false)

# Process a single attack
func process_attack(attacker: Unit, defender: Unit) -> void:
	# Check if attack hits
	if calculate_hit(attacker, defender):
		# Check for critical hit
		var is_critical = calculate_critical(attacker, defender)
		
		# Calculate and apply damage
		var damage = calculate_damage(attacker, defender, is_critical)
		apply_damage(defender, damage)
		
		# Emit signal for UI updates
		unit_damaged.emit(defender, damage)

# Apply damage to a unit
func apply_damage(unit: Unit, damage: int) -> void:
	unit.health -= damage
	unit.health = max(0, unit.health)

# Apply healing to a unit
func apply_healing(unit: Unit, amount: int) -> void:
	unit.health += amount
	unit.health = min(unit.health, unit.max_health)
	
	# Emit signal for UI updates
	unit_healed.emit(unit, amount)

# Check if unit can counter-attack
func can_counter_attack(attacker: Unit, defender: Unit) -> bool:
	# Check if defender is in range to counter
	var distance = grid_system.get_distance(attacker.grid_position, defender.grid_position)
	return distance <= defender.attack_range and defender.can_counter_attack

# Check if unit can perform a follow-up attack
func can_follow_up(attacker: Unit, defender: Unit) -> bool:
	# In Fire Emblem, units can follow up if they're significantly faster
	return attacker.speed >= (defender.speed + 5) 
