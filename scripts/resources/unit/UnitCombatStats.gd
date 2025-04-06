extends Resource
class_name UnitCombatStats

var max_health: int = 10
var strength: int = 5
var skill: int = 5
var magic: int = 2
var defense: int = 5
var resistance: int = 2
var speed: int = 5
var movement: int = 8
var attack_range: int = 1
var min_attack_range: int = 1
var experience: int = 0
var exp_to_level: int = 100

var growth_rates: Dictionary = {
	"hp": 60,
	"strength": 10,
	"skill": 10,
	"magic": 10,
	"defense": 10,
	"resistance": 10,
	"speed": 10
}

func _init( p_max_health: int = 10,
			p_strength: int = 5,
			p_skill: int = 5,
			p_magic: int = 2,
			p_defense: int = 5,
			p_resistance: int = 2,
			p_speed: int = 5,
			p_movement: int = 8,
			p_attack_range: int = 1,
			p_min_attack_range: int = 1,
			p_experience: int = 0,
			p_exp_to_level: int = 100,
			p_growth_rates: Dictionary = growth_rates):
	max_health = p_max_health
	strength = p_strength
	skill = p_skill
	magic = p_magic
	defense = p_defense
	resistance = p_resistance
	speed = p_speed
	movement = p_movement
	attack_range = p_attack_range
	min_attack_range = p_min_attack_range
	experience = p_experience
	exp_to_level = p_exp_to_level
	growth_rates = p_growth_rates


static func create(params: Dictionary) -> UnitCombatStats:
	return UnitCombatStats.new(
		params.get("max_health", 10),
		params.get("strength", 5),
		params.get("skill", 5),
		params.get("magic", 2),
		params.get("defense", 5),
		params.get("resistance", 2),
		params.get("speed", 5),
		params.get("movement", 8),
		params.get("attack_range", 1),
		params.get("min_attack_range", 1),
		params.get("experience", 0),
		params.get("exp_to_level", 100),
		params.get("growth_rates", {})
	)
