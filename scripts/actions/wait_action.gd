class_name WaitAction
extends Action

func _init():
	super._init("Wait", null, "End turn")

func execute(character: Character):
	character.deselect()
	character.actions.use_action()
	character.set_state(character.CharacterState.INACTIVE)
	super.execute(character)
