extends Node
class_name TurnManager

var current_faction_index: int = 0
var factions: Array[Faction] = []
var characters_by_faction: Dictionary = {}

func _ready():
	EventBus.character_action_used.connect(_check_character_turn_end)

func start_game(p_characters):
	# Create unique faction list from characters
	var faction_set = {}
	for character in p_characters:
		var faction = character.stats.faction
		if not faction_set.has(faction.value):
			faction_set[faction.value] = faction
			factions.append(faction)
			characters_by_faction[faction.value] = []
		characters_by_faction[faction.value].append(character)
		
		character.reset_action_tracking()
		
	current_faction_index = 0
	start_faction_turn(factions[current_faction_index])

func start_faction_turn(faction: Faction):
	for character in characters_by_faction[faction.value]:
		character.is_my_turn = true
	EventBus.faction_turn_changed.emit(faction)

func end_faction_turn(faction):
	# Reset all character actions for this faction
	for character in characters_by_faction[faction.value]:
		character.is_my_turn = false
		character.reset_action_tracking()
	current_faction_index = (current_faction_index + 1) % factions.size()
	start_faction_turn(factions[current_faction_index])
	
func is_characters_turn(character: Character) -> bool:
	return character.stats.faction.value == factions[current_faction_index].value 

func _check_character_turn_end(_character):
	# Check if all characters in current faction have used their actions
	var current_faction = factions[current_faction_index]
	var all_characters_done = true
	
	for f_character in characters_by_faction[current_faction.value]:
		if f_character.actions.has_available_actions():
			all_characters_done = false
			break
	
	if all_characters_done:
		end_faction_turn(current_faction)
		
