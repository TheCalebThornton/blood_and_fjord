extends Node2D
class_name BattleManager

const MIN_HIT_CHANCE = 0.1  # 10% minimum hit chance
const MAX_HIT_CHANCE = 1.0  # 100% maximum hit chance
const CRITICAL_MULTIPLIER = 1.5  # Critical hits do 50% more damage

# Preloaded assets
const FloatingTextScene = preload("res://scenes/ui/FloatingText.tscn")
const BloodEffectScene = preload("res://scenes/effects/CombatEffect.tscn")

# Signals
signal combat_started(attacker: GameUnit, defender: GameUnit)
signal combat_ended(attacker: GameUnit, defender: GameUnit, defeated: bool)
#signal unit_damaged(unit: GameUnit, damage: int)
signal unit_healed(unit: GameUnit, amount: int)

@onready var grid_system: GridSystem = $"../GridSystem"
@onready var unit_manager: UnitManager = $"../UnitManager"
@onready var game_camera: Camera2D = $"/root/Main/GameCamera"

func reset() -> void:
	# Reset any battle-specific state
	pass

func calculate_hit(attacker: GameUnit, defender: GameUnit) -> bool:
	var hit_chance = calculate_hit_chance(attacker, defender)
	return randf() <= hit_chance

func calculate_hit_chance(attacker: GameUnit, defender: GameUnit) -> float:
	var base_hit_chance = attacker.accuracy / 100.0
	var evasion_modifier = defender.evasion / 100.0
	
	var final_hit_chance = base_hit_chance * (1.0 - evasion_modifier)
	return clampf(final_hit_chance, MIN_HIT_CHANCE, MAX_HIT_CHANCE)

func calculate_critical(attacker: GameUnit, defender: GameUnit) -> bool:
	var crit_chance = calculate_critical_chance(attacker, defender)
	return randf() <= crit_chance
	
func calculate_critical_chance(attacker: GameUnit, defender: GameUnit):
	# TODO apply Luck stat?
	return attacker.critical / 100.0

func calculate_damage(attacker: GameUnit, defender: GameUnit, is_critical: bool = false) -> int:
	var base_damage = max(1, attacker.attack - defender.defense)
	
	if is_critical:
		base_damage = int(base_damage * CRITICAL_MULTIPLIER)
	
	# Apply weapon type effectiveness (can be expanded later)
	# TODO: Implement weapon triangle and effectiveness
	
	return base_damage

func execute_combat(attacker: GameUnit, defender: GameUnit) -> void:
	combat_started.emit(attacker, defender)
	
	await process_attack(attacker, defender)
	
	if defender.health <= 0:
		combat_ended.emit(attacker, defender, true)
		return
	
	if can_counter_attack(attacker, defender):
		await process_attack(defender, attacker)
		
		if attacker.health <= 0:
			combat_ended.emit(defender, attacker, true)
			return
	
	if can_follow_up(attacker, defender):
		await process_attack(attacker, defender)
 
		if defender.health <= 0:
			combat_ended.emit(attacker, defender, true)
			return
	
	# Signal that combat has ended with no defeats
	combat_ended.emit(attacker, defender, false)

func process_attack(attacker: GameUnit, defender: GameUnit) -> void:
	await animate_attack(attacker, defender)
	
	if calculate_hit(attacker, defender):
		var is_critical = calculate_critical(attacker, defender)
		var damage = calculate_damage(attacker, defender, is_critical)
		await apply_damage(defender, damage, is_critical)
	else:
		show_floating_text(defender, "MISS", FloatingText.TextType.MISS)

func apply_damage(unit: GameUnit, damage: int, is_critical: bool = false) -> void:
	show_floating_text(unit, str(damage), 
		FloatingText.TextType.CRITICAL if is_critical else FloatingText.TextType.DAMAGE)
	if is_critical:
		game_camera.shake(10.0, 0.3)
	spawn_effect(unit.position, BloodEffectScene)
	await unit.take_damage(damage)

func apply_healing(unit: GameUnit, amount: int) -> void:
	unit.health += amount
	unit.health = min(unit.health, unit.max_health)
	show_floating_text(unit, str(amount), FloatingText.TextType.HEAL)
	unit_healed.emit(unit, amount)

func show_floating_text(unit: GameUnit, text: String, type: int) -> void:
	var floating_text = FloatingTextScene.instantiate()
	floating_text.text = text
	floating_text.type = type
	floating_text.position = unit.position + Vector2(-20, -30)  # Position above unit's head
	add_child(floating_text)

func can_counter_attack(attacker: GameUnit, defender: GameUnit) -> bool:
	# Check if defender is in range to counter
	var distance = grid_system.get_distance(attacker.grid_position, defender.grid_position)
	return distance <= defender.attack_range and defender.can_counter_attack

func can_follow_up(attacker: GameUnit, defender: GameUnit) -> bool:
	return attacker.speed >= (defender.speed + 5) 

func animate_attack(attacker: GameUnit, target: GameUnit) -> void:
	var direction = target.position - attacker.position
	
	# Store the animation completion promise
	var animation_finished = attacker.sprite.animation_finished
	
	# Set the attack direction
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			attacker.set_state(GameUnit.UnitState.ATTACK_RIGHT)
		else:
			attacker.set_state(GameUnit.UnitState.ATTACK_LEFT)
	else:
		if direction.y > 0:
			attacker.set_state(GameUnit.UnitState.ATTACK_DOWN)
		else:
			attacker.set_state(GameUnit.UnitState.ATTACK_UP)

	await animation_finished
	attacker.set_state(GameUnit.UnitState.IDLE)

func spawn_effect(pos: Vector2, effect) -> void:
	var effectInstance = effect.instantiate()
	effectInstance.position = pos
	add_child(effectInstance)
