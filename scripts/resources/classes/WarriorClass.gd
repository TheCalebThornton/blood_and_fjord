extends GameUnit

func _ready():
	super._ready()
	
	# Base stats
	unit_class = UnitClass.WARRIOR
	max_health = 15
	health = max_health
	movement = 5
	attack = 7
	defense = 6
	magic = 1
	resistance = 3
	speed = 5
	accuracy = 90
	evasion = 15
	critical = 10
	attack_range = 1
	min_attack_range = 1
	
	growth_rates = {
		"hp": 75,        # High HP growth
		"attack": 60,    # High attack growth
		"defense": 45,   # Good defense growth
		"magic": 10,     # Poor magic growth
		"resistance": 25, # Low-medium resistance growth
		"speed": 40      # Medium speed growth
	}
	
	available_actions = [
		{"name": "Attack", "id": "attack"},
		{"name": "Wait", "id": "wait"}
	]
