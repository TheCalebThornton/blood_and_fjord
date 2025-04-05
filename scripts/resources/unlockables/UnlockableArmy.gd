extends Node2D
class_name UnlockableArmy

var id: int
var army_name: String
var units: Array[UnitData] # Array of unit dictionaries with name, class, color, level
var auras: Array # Array of aura ids
var condition: UnlockCondition

func _init(p_id: int, p_name: String, p_condition: UnlockCondition, p_units: Array = [], p_auras: Array = []) -> void:
	id = p_id
	army_name = p_name
	condition = p_condition 
	units = p_units
	auras = p_auras

static func create(params: Dictionary) -> UnlockableArmy:
	var unitDatas: Array[UnitData] = []
	for unit in params.get("units", []):
		unitDatas.append(UnitData.create(unit))

	return UnlockableArmy.new(
		params.get("id", 0),
		params.get("name", ""),
		params.get("condition", null),
		unitDatas,
		params.get("auras", [])
	)
