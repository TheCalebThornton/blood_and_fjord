extends Resource
class_name Faction

enum FACTION_ENUM {
	PLAYER,
	ENEMY,
	OTHER
}

@export var value: FACTION_ENUM

func get_faction_name() -> String:
	return FACTION_ENUM.keys()[value].capitalize()
