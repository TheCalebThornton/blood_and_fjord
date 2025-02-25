extends Resource
class_name Faction

enum FactionEnum {
	PLAYER,
	ENEMY,
	OTHER
}

@export var value: FactionEnum

func get_faction_name() -> String:
	return FactionEnum.keys()[value].capitalize()
