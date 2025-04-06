extends Node
class_name UnitFactory

var unit_scenes: Dictionary = {
	GameUnit.UnitClass.WARRIOR: preload("res://scenes/units/classes/Warrior.tscn"),
	# TODO: Add other unit classes as they're implemented
}

func create_unit(unit_data: UnitData, faction: int) -> GameUnit:
	if not unit_scenes.has(unit_data.unit_class):
		push_error("No scene found for unit class: %s" % GameUnit.UnitClass.keys()[unit_data.unit_class])
		return null
	
	var unit_instance = unit_scenes[unit_data.unit_class].instantiate()
	
	unit_instance.unit_name = unit_data.unit_name
	unit_instance.unit_class = unit_data.unit_class
	unit_instance.faction = faction
	unit_instance.level = unit_data.level
	if (unit_data.combat_stats):
		unit_instance.combat_stats = unit_data.combat_stats
		unit_instance.health = unit_instance.combat_stats.max_health
	else:
		unit_instance.apply_levels()
	
	var unit_class = GameUnit.UnitClass.keys()[unit_data.unit_class]
	unit_instance.sprite_frames_res = load("res://scripts/resources/animatedSprites/%s/%s%s.tres" % 
		[unit_class, unit_data.sprite_color, unit_class])
	unit_instance.ui_icon_image = load("res://assets/Factions/Knights/Troops/%s/%s/portrait.png" % 
		[unit_class, unit_data.sprite_color])
	
	return unit_instance
