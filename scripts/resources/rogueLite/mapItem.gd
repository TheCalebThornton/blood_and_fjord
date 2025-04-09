extends Resource
class_name MapItem

enum ItemType {
	MULTI_HEART,
	HEART,
	CHEST
}

enum RewardType {
	# CLASS_PROMO, Applied outside of RNG
	STAT_BOOST,
	AURA_UPRANK
}

enum StatType {
	HP,
	STR,
	MAG,
	SKILL,
	DEF,
	RES,
	SPEED,
	MOVE
}

const STAT_WEIGHTS = {
	StatType.HP: 8,
	StatType.STR: 5,
	StatType.MAG: 5,
	StatType.SKILL: 5,
	StatType.DEF: 5,
	StatType.RES: 5,
	StatType.SPEED: 5,
	StatType.MOVE: 1  # Lower weight means less likely to be chosen
}

# Configuration constants
const MULTI_HEART_HP_BOOST = 0.3  # 30% HP boost
const HEART_HP_BOOST = 1.0        # 100% HP boost
const MIN_CHEST_REWARDS = 1
const MAX_CHEST_REWARDS = 3

var item_scenes: Dictionary = {
	ItemType.MULTI_HEART: preload("res://scenes/units/classes/Warrior.tscn"),
	ItemType.HEART: preload("res://scenes/units/classes/Warrior.tscn"),
	ItemType.CHEST: preload("res://scenes/units/classes/Warrior.tscn"),
	# Trap item?
	# TODO: Add other items as they're implemented
}

# TODO - we need a UI and graphic for the chest rewards

var type: ItemType = ItemType.HEART
var grid_position: Vector2i

func _init(item_type: String = "heart"):
	match item_type.to_lower():
		"multi_heart":
			type = ItemType.MULTI_HEART
		"heart":
			type = ItemType.HEART
		"chest":
			type = ItemType.CHEST


func apply_effect(targets: Array[GameUnit]) -> void:
	match type:
		ItemType.MULTI_HEART:
			_apply_multi_heart(targets)
		ItemType.HEART:
			if targets.size() > 0:
				_apply_heart(targets[0])
		ItemType.CHEST:
			if targets.size() > 0:
				_apply_chest(targets[0])

func _apply_multi_heart(targets: Array[GameUnit]) -> void:
	for unit in targets:
		var hp_increase = unit.max_hp * MULTI_HEART_HP_BOOST
		unit.max_hp += hp_increase
		unit.current_hp += hp_increase

func _apply_heart(unit: GameUnit) -> void:
	var hp_increase = unit.max_hp * HEART_HP_BOOST
	unit.max_hp += hp_increase
	unit.current_hp += hp_increase

func _apply_chest(unit: GameUnit) -> void:
	var num_rewards = randi_range(MIN_CHEST_REWARDS, MAX_CHEST_REWARDS)
	
	for _i in range(num_rewards):
		if unit.can_promote:
			_apply_class_promotion(unit)
			continue
		var reward_type = randi() % RewardType.size()
		match reward_type:
			RewardType.STAT_BOOST:
				_apply_stat_boost(unit)
			RewardType.AURA_UPRANK:
				_apply_aura_uprank(unit)

func _apply_stat_boost(unit: GameUnit) -> void:
	var total_weight = 0
	for weight in STAT_WEIGHTS.values():
		total_weight += weight
	
	var roll = randi() % total_weight
	var current_weight = 0
	var stat = StatType.HP
	
	for stat_type in STAT_WEIGHTS:
		current_weight += STAT_WEIGHTS[stat_type]
		if roll < current_weight:
			stat = stat_type
			break
	
	var boost_amount = 0
	match stat:
		StatType.HP:
			boost_amount = randi_range(1, 5)
			unit.combat_stats.max_hp += boost_amount
			unit.health += boost_amount
		StatType.STR:
			boost_amount = randi_range(1, 2)
			unit.combat_stats.strength += boost_amount
		StatType.MAG:
			boost_amount = randi_range(1, 2)
			unit.combat_stats.magic += boost_amount
		StatType.SKILL:
			boost_amount = randi_range(1, 2)
			unit.combat_stats.skill += boost_amount
		StatType.DEF:
			boost_amount = randi_range(1, 2)
			unit.combat_stats.defense += boost_amount
		StatType.RES:
			boost_amount = randi_range(1, 2)
			unit.combat_stats.resistance += boost_amount
		StatType.SPEED:
			boost_amount = randi_range(1, 2)
			unit.combat_stats.speed += boost_amount
		StatType.MOVE:
			boost_amount = 1
			unit.combat_stats.move += boost_amount


func _apply_class_promotion(unit: GameUnit) -> void:
	if unit.can_promote:
		unit.promote()

# TODO implement after Aura
func _apply_aura_uprank(_unit: GameUnit) -> void:
	pass
	# if unit.has_aura():
	#     unit.upgrade_aura()

func get_description() -> String:
	match type:
		ItemType.MULTI_HEART:
			return "Multi-Heart: Increases max HP of all units by 30%"
		ItemType.HEART:
			return "Heart: Doubles the max HP of one unit"
		ItemType.CHEST:
			return "Chest: Contains {min}-{max} rewards (stat boost, class promotion, or aura upgrade)".format({"min": MIN_CHEST_REWARDS, "max": MAX_CHEST_REWARDS})
		_:
			return "Unknown item"
