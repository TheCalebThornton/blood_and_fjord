extends PanelContainer
class_name UnitOverviewUI

@onready var unit_portrait = $MarginContainer/VBoxContainer/HBoxContainer/Portrait
@onready var unit_name_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/UnitName
@onready var lvl_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Level
@onready var hp_label = $MarginContainer/VBoxContainer/HPLabel
@onready var hp_bar = $MarginContainer/VBoxContainer/HPBar

# Dictionary to store unit portrait textures
var portrait_textures = {
	# TODO These asset paths will need to come from save file eventually
	"warrior": preload("res://assets/Factions/Knights/Troops/Warrior/Blue/Warrior_Blue_portrait.png"),
	#"archer": preload("res://assets/portraits/archer.png"),
	#"mage": preload("res://assets/portraits/mage.png"),
	# Add more unit types as needed
	"default": preload("res://assets/Factions/Knights/Troops/Warrior/Blue/Warrior_Blue_portrait.png")
}

func _ready():
	hide_unit_stats()

func show_unit_stats(unit: GameUnit, is_player: bool = true):
	unit_name_label.text = unit.unit_name
	lvl_label.text = "Level: %s" % [str(unit.level)]
	
	hp_label.text = "HP: %d/%d" % [unit.health, unit.max_health]
	hp_bar.max_value = unit.max_health
	hp_bar.value = unit.health
	
	var portrait_key = "default"
	unit_portrait.texture = portrait_textures[portrait_key]
	
	if is_player:
		unit_name_label.add_theme_color_override("font_color", Color(0, 0.7, 1))
		hp_bar.modulate = Color(0, 0.7, 1)
	else:
		unit_name_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		hp_bar.modulate = Color(1, 0.3, 0.3)

	show()

func hide_unit_stats():
	hide()
