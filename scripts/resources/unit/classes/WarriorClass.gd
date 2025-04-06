extends GameUnit

func _init():
	combat_stats = UnitCombatStats.create({
		"max_health": 7,
		"strength": 5,
		"magic": 1,
		"skill": 3,
		"defense": 2,
		"resistance": 1,
		"speed": 5,
		"movement": 5,
		"attack_range": 1,
		"min_attack_range": 1,
		"growth_rates": {
			"hp": 75,
			"strength": 60,
			"magic": 10,
			"skill": 10,
			"defense": 45,
			"resistance": 25,
			"speed": 40
		}
	})

	unit_class = UnitClass.WARRIOR
	attack_type = GameUnit.AttackType.PHYSICAL
	health = combat_stats.max_health  # Initialize health to max health
	
	available_actions = [
		{"name": "Attack", "id": "attack"},
		{"name": "Wait", "id": "wait"}
	]
