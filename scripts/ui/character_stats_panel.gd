extends Panel
class_name CharacterStatsPanel

@onready var name_label = $MarginContainer/VBoxContainer/NameLabel
@onready var level_label = $MarginContainer/VBoxContainer/StatsGrid/LevelValue
@onready var hp_label = $MarginContainer/VBoxContainer/StatsGrid/HPValue
@onready var strength_label = $MarginContainer/VBoxContainer/StatsGrid/StrengthValue
@onready var defense_label = $MarginContainer/VBoxContainer/StatsGrid/DefenseValue
@onready var speed_label = $MarginContainer/VBoxContainer/StatsGrid/SpeedValue
@onready var movement_label = $MarginContainer/VBoxContainer/StatsGrid/MovementValue

func _ready():
	hide()
	EventBus.character_selected.connect(_on_character_selected)
	EventBus.character_deselected.connect(_on_character_deselected)

func _on_character_selected(character: Character):
	var viewport_width = get_viewport_rect().size.x
	var character_screen_position = get_viewport().get_camera_2d().get_screen_center_position() - character.position
	
	if character.position.x > get_viewport().get_camera_2d().position.x:
		position.x = -(viewport_width / 2)
	else:
		position.x = (viewport_width / 2) - size.x
		
	
	show()
	update_stats(character)

func _on_character_deselected(_character: Character):
	hide()

func update_stats(character: Character):
	name_label.text = character.stats.name + " | " + character.stats.faction.get_faction_name()
	level_label.text = str(character.stats.level)
	hp_label.text = str(character.stats.get_current_hp())
	strength_label.text = str(character.stats.get_strength())
	defense_label.text = str(character.stats.get_defense())
	speed_label.text = str(character.stats.get_speed())
	movement_label.text = str(character.stats.get_movement()) 
