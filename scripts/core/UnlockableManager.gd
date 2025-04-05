extends Node2D
class_name UnlockableManager

@onready var player_data: PlayerSaveData = $"/root/Main/GameManager/PlayerSaveData"

var unlocked_armies: Array[UnlockableArmy] = []
var unlocked_auras: Array[UnlockableAura] = []

var unlockable_armies: Array[UnlockableArmy] = [
	UnlockableArmy.create({
		"id": 1,
		"name": "Raiders",
		"units": [
			{
				"name": "Blu",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Blue",
				"level": 2,
			},			
			{
				"name": "Purp",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Purple",
				"level": 1,
			},
			{
				"name": "Yell",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Yellow",
				"level": 1,
			}
		],
		"auras": [],
		"condition": null
	}),
	UnlockableArmy.create({
		"id": 2,
		"name": "Solo Player",
		"units": [
			{
				"name": "Kirito",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Purple",
				"level": 7,
			}
		],
		"auras": [],
		"condition": null
	}),
	UnlockableArmy.create({
		"id": 3,
		"name": "Shield Bros",
		"units": [
			{
				"name": "Braum",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Blue",
				"level": 3,	
			},
			{
				"name": "Jorgen",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Yellow",
				"level": 3,
			}
		],
		"auras": [],
		"condition": UnlockCondition.create({
			"type": UnlockCondition.UnlockType.MAP_CLEAR,
			"map": 1
		})
	}),
	UnlockableArmy.create({
		"id": 4,
		"name": "Test Army",
		"units": [
			{
				"name": "bb",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Purple",
				"level": 3,	
			},
			{
				"name": "jj",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Yellow",
				"level": 3,
			}
		],
		"auras": [],
		"condition": UnlockCondition.create({
			"type": UnlockCondition.UnlockType.MAP_CLEAR,
			"map": 5
		})
	}),
	UnlockableArmy.create({
		"id": 5,
		"name": "Test Army",
		"units": [
			{
				"name": "bb",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Purple",
				"level": 3,	
			},
			{
				"name": "jj",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Yellow",
				"level": 3,
			}
		],
		"auras": [],
		"condition": UnlockCondition.create({
			"type": UnlockCondition.UnlockType.MAP_CLEAR,
			"map": 5
		})
	}),
	UnlockableArmy.create({
		"id": 6,
		"name": "Test Army 2",
		"units": [
			{
				"name": "xx",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Purple",
				"level": 3,	
			},
			{
				"name": "yy",
				"class": GameUnit.UnitClass.WARRIOR,
				"color": "Yellow",
				"level": 3,
			}
		],
		"auras": [],
		"condition": UnlockCondition.create({
			"type": UnlockCondition.UnlockType.MAP_CLEAR,
			"map": 5
		})
	})
]

var unlockable_auras: Array[UnlockableAura] = [
	UnlockableAura.create({
		"id": 1,
		"name": "Re-roll",
		"description": "Re-roll during Aura selection",
		"condition": UnlockCondition.create({
			"type": UnlockCondition.UnlockType.MAP_CLEAR,
			"map": 2,
			"rounds": 5
		})
	})
]


func get_unlocked_armies() -> Array[UnlockableArmy]:
	var evaled_unlocked_armies = unlockable_armies.filter(func(ua): 
		return unlocked_armies.has(ua) or\
			player_data.unlocked_armies.has(ua.id) or\
			ua.condition == null or\
			ua.condition.evaluate(player_data)
	)
	unlocked_armies = evaled_unlocked_armies
	return evaled_unlocked_armies

func get_locked_armies() -> Array[UnlockableArmy]:
	return unlockable_armies.filter(func(ua): return not get_unlocked_armies().has(ua))

func get_unlocked_auras() -> Array[UnlockableAura]:
	var evaled_unlocked_auras = unlockable_auras.filter(func(ua): 
		return unlocked_auras.has(ua) or\
			player_data.unlocked_auras.has(ua.id) or\
			ua.condition == null or\
			ua.condition.evaluate(player_data)
	)
	unlocked_auras = evaled_unlocked_auras
	return evaled_unlocked_auras

func get_locked_auras() -> Array[UnlockableAura]:
	return unlocked_auras.filter(func(ua): return not get_unlocked_auras().has(ua))
