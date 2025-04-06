extends Resource
class_name UnitData

var unit_name: String = "Unit"
var unit_class: GameUnit.UnitClass = GameUnit.UnitClass.WARRIOR
var sprite_color: String = "Blue"
var level: int = 1
var combat_stats: UnitCombatStats = UnitCombatStats.new()

func _init(p_name: String = "Unit", 
		  p_class: GameUnit.UnitClass = GameUnit.UnitClass.WARRIOR,
		  p_color: String = "Blue",
		  p_level: int = 1,
		  p_combat_stats: UnitCombatStats = null):
	unit_name = p_name
	unit_class = p_class
	sprite_color = p_color
	level = p_level
	combat_stats = p_combat_stats

static func create(params: Dictionary) -> UnitData:
	return UnitData.new(
		params.get("name", ""),
		params.get("class", GameUnit.UnitClass.WARRIOR),
		params.get("color", "Blue"),
		params.get("level", 1),
		params.get("combat_stats", null)
	)
