class_name CharacterActions
extends RefCounted

var character: Character
var can_move: bool = true
var can_act: bool = true

func _init(p_character: Character):
	character = p_character

func reset():
	can_move = true
	can_act = true

func has_available_actions() -> bool:
	return can_move or can_act

func is_acting() -> bool:
	return character.selected && can_act

func use_move():
	can_move = false

func use_action():
	can_act = false

func get_available_actions() -> Array[Action]:
	var actions: Array[Action] = []
	
	# Only add actions if the character can still act
	if can_act:
		actions.append(AttackAction.new())
		actions.append(WaitAction.new())
		if character.stats.classStats.can_heal:
			actions.append(HealAction.new())
	
	return actions 
