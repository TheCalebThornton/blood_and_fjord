extends Resource
class_name CharacterStats

@export var name: String
@export var faction: Faction
@export var classStats: ClassStats
@export var level: int = 1
@export var movement: int
var current_hp: int

func _init():
	current_hp = get_max_hp()

func get_max_hp() -> int:
	return classStats.max_hp_scale * level if classStats else 0

func get_current_hp() -> int:
	return current_hp

func set_current_hp(new_hp: int) -> void:
	current_hp = clampi(new_hp, 0, get_max_hp())

func take_damage(damage: int) -> void:
	set_current_hp(current_hp - damage)

func heal(amount: int) -> void:
	set_current_hp(current_hp + amount)

func get_strength() -> int:
	return classStats.strength_scale * level

func get_defense() -> int:
	return classStats.defense_scale * level

func get_speed() -> int:
	return classStats.speed_scale * level

func get_movement() -> int:
	return movement
