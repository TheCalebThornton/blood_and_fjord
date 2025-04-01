extends Resource
class_name UnitData

@export var unit_name: String = "Unit"
@export var unit_class: GameUnit.UnitClass = GameUnit.UnitClass.WARRIOR
@export var sprite_color: String = "Blue"
@export var level: int = 1

func _init(p_name: String = "Unit", 
		  p_class: GameUnit.UnitClass = GameUnit.UnitClass.WARRIOR,
		  p_color: String = "Blue",
		  p_level: int = 1):
	unit_name = p_name
	unit_class = p_class
	sprite_color = p_color
	level = p_level
