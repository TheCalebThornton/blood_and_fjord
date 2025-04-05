extends Node2D
class_name UnlockableAura

var id: int
var aura_name: String
var description: String
var condition: UnlockCondition

func _init(p_id: int, p_name: String, p_condition: UnlockCondition, p_description: String = "", ) -> void:
	id = p_id
	aura_name = p_name
	condition = p_condition 
	description = p_description

static func create(params: Dictionary) -> UnlockableAura:
	return UnlockableAura.new(
		params.get("id", 0),
		params.get("name", ""),
		params.get("condition", UnlockCondition.create({})),
		params.get("description", "")
	)
