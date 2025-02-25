extends Panel
class_name CharacterStatsPanel

@onready var name_label = $MarginContainer/VBoxContainer/NameLabel
@onready var level_label = $MarginContainer/VBoxContainer/StatsGrid/LevelValue
@onready var hp_label = $MarginContainer/VBoxContainer/StatsGrid/HPValue
@onready var strength_label = $MarginContainer/VBoxContainer/StatsGrid/StrengthValue
@onready var defense_label = $MarginContainer/VBoxContainer/StatsGrid/DefenseValue
@onready var speed_label = $MarginContainer/VBoxContainer/StatsGrid/SpeedValue

func _ready():
	var theme_setup = preload("res://themes/setup_theme.gd").new()
	theme = theme_setup.setup_theme()

func update_stats(character: Character):
	name_label.text = character.stats.name + " | " + character.stats.faction.get_faction_name()
	level_label.text = str(character.stats.level)
	hp_label.text = str(character.stats.get_current_hp())
	strength_label.text = str(character.stats.get_strength())
	defense_label.text = str(character.stats.get_defense())
	speed_label.text = str(character.stats.get_speed()) 
