class_name Action
extends Resource

var name: String
var icon: Texture2D
var description: String

func _init(p_name: String, p_icon: Texture2D = null, p_description: String = ""):
	name = p_name
	icon = p_icon
	description = p_description

func can_execute(character: Character) -> bool:
	return character.actions.has_available_actions()

func execute(character: Character):
	character.close_actions_menu()
	EventBus.character_action_used.emit(character)
