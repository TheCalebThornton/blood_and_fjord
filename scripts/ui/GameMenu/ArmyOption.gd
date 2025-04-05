extends VBoxContainer
class_name ArmyOption

var army: UnlockableArmy
var is_unlocked: bool

func _init(p_army: UnlockableArmy, p_is_unlocked: bool) -> void:
	army = p_army
	is_unlocked = p_is_unlocked
