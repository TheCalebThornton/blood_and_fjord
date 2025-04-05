extends Node2D
class_name UnlockCondition

enum UnlockType {
	MAP_CLEAR,
	ROUNDS_SURVIVED,
	DAMAGE_TAKEN,
	ALLIES_DEFEATED,
	ENEMIES_DEFEATED,
	NONE
}

var type: UnlockType = UnlockType.NONE
var map: int = -1
var rounds: int = -1
var damage_taken: int = -1
var allies_defeated: int = -1
var enemies_defeated: int = -1

func _init(p_type: UnlockType = UnlockType.NONE, p_map: int = -1, p_rounds: int = -1, p_damage_taken: int = -1, p_allies_defeated: int = -1, p_enemies_defeated: int = -1) -> void:
	type = p_type
	map = p_map
	rounds = p_rounds
	damage_taken = p_damage_taken
	allies_defeated = p_allies_defeated
	enemies_defeated = p_enemies_defeated

static func create(params: Dictionary) -> UnlockCondition:
	return UnlockCondition.new(
		params.get("type", UnlockType.NONE),
		params.get("map", -1),
		params.get("rounds", -1),
		params.get("damage_taken", -1),
		params.get("allies_defeated", -1),
		params.get("enemies_defeated", -1)
	)

func evaluate(player_data: PlayerSaveData) -> bool:
	match type:
		UnlockType.MAP_CLEAR:
			return player_data.current_level >= map
		UnlockType.ROUNDS_SURVIVED:
			return player_data.rounds_survived >= rounds
		UnlockType.DAMAGE_TAKEN:
			return player_data.damage_taken <= damage_taken
		UnlockType.ALLIES_DEFEATED:
			return player_data.allies_defeated <= allies_defeated
		UnlockType.ENEMIES_DEFEATED:
			return player_data.enemies_defeated >= enemies_defeated
		_:
			return false 
