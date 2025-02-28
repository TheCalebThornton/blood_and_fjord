extends Button
class_name ActionButton

var action: Action
var character: Character

func setup(p_action: Action, p_character: Character):
	character = p_character
	action = p_action
	text = action.name
	if action.icon:
		icon = action.icon
	tooltip_text = action.description
	pressed.connect(_on_pressed)

func _on_pressed():
	if action.can_execute(character):
		action.execute(character)
