extends PanelContainer
class_name BattleForecast

var color_dict: Dictionary = {
	GameUnit.Faction.PLAYER: Color(0.2, 0.6, 1.0),
	GameUnit.Faction.ENEMY: Color(1.0, 0.2, 0.2),
	GameUnit.Faction.ALLY: Color(0.2, 0.8, 0.2)
}

@onready var attacker_panel = $MarginContainer/VBoxContainer/AttackerPanel
@onready var attacker_name_label = $MarginContainer/VBoxContainer/AttackerPanel/VBoxContainer/Name
@onready var attacker_hp_bar = $MarginContainer/VBoxContainer/AttackerPanel/VBoxContainer/HPBar
@onready var defender_panel = $MarginContainer/VBoxContainer/DefenderPanel
@onready var defender_name_label = $MarginContainer/VBoxContainer/DefenderPanel/VBoxContainer/Name
@onready var defender_hp_bar = $MarginContainer/VBoxContainer/DefenderPanel/VBoxContainer/HPBar

@onready var attacker_column_panel = $MarginContainer/VBoxContainer/HBoxContainer/AttackerColumnPanel
@onready var attacker_hp_label = $MarginContainer/VBoxContainer/HBoxContainer/AttackerColumnPanel/AttackerColumn/aHp
@onready var attacker_atk_label = $MarginContainer/VBoxContainer/HBoxContainer/AttackerColumnPanel/AttackerColumn/aAtk
@onready var attacker_hit_label = $MarginContainer/VBoxContainer/HBoxContainer/AttackerColumnPanel/AttackerColumn/aHit
@onready var attacker_crit_label = $MarginContainer/VBoxContainer/HBoxContainer/AttackerColumnPanel/AttackerColumn/aCrit

@onready var defender_column_panel = $MarginContainer/VBoxContainer/HBoxContainer/DefenderColumnPanel
@onready var defender_hp_label = $MarginContainer/VBoxContainer/HBoxContainer/DefenderColumnPanel/DefenderColumn/dHp
@onready var defender_atk_label = $MarginContainer/VBoxContainer/HBoxContainer/DefenderColumnPanel/DefenderColumn/dAtk
@onready var defender_hit_label = $MarginContainer/VBoxContainer/HBoxContainer/DefenderColumnPanel/DefenderColumn/dHit
@onready var defender_crit_label = $MarginContainer/VBoxContainer/HBoxContainer/DefenderColumnPanel/DefenderColumn/dCrit

func _ready():
	hide_forecast()
	# TODO add number value instead of percentage to HP bar. This requires Label overlay
	#attacker_hp_bar.value_changed.connect(_on_attacker_hp_changed)
	#defender_hp_bar.value_changed.connect(_on_defender_hp_changed)


func show_forecast(attacker: GameUnit, defender: GameUnit, battle_manager: BattleManager):
	var attacker_style_box = StyleBoxFlat.new()
	attacker_style_box.bg_color = color_dict.get(attacker.faction)
	var defender_style_box = StyleBoxFlat.new()
	defender_style_box.bg_color = color_dict.get(defender.faction)
	
	attacker_panel.add_theme_stylebox_override("panel", attacker_style_box)
	attacker_column_panel.add_theme_stylebox_override("panel", attacker_style_box)
	defender_panel.add_theme_stylebox_override("panel", defender_style_box)
	defender_column_panel.add_theme_stylebox_override("panel", defender_style_box)
	attacker_name_label.text = attacker.unit_name
	attacker_hp_bar.min_value = 0
	attacker_hp_bar.max_value = attacker.combat_stats.max_health
	attacker_hp_bar.value = attacker.health
	var attacker_dmg = battle_manager.calculate_damage(attacker, defender)
	attacker_atk_label.text = str(attacker_dmg)
	attacker_hit_label.text = str(int(round(battle_manager.calculate_hit_chance(attacker, defender) * 100))) + "%"
	attacker_crit_label.text = str(int(round(battle_manager.calculate_critical_chance(attacker, defender) * 100))) + "%"
	
	defender_name_label.text = defender.unit_name
	defender_hp_bar.min_value = 0
	defender_hp_bar.max_value = defender.combat_stats.max_health
	defender_hp_bar.value = defender.health
	var defender_dmg = battle_manager.calculate_damage(defender, attacker)
	defender_atk_label.text = str(defender_dmg)
	defender_hit_label.text = str(int(round(battle_manager.calculate_hit_chance(defender, attacker) * 100))) + "%"
	defender_crit_label.text = str(int(round(battle_manager.calculate_critical_chance(defender, attacker) * 100))) + "%"
	
	attacker_hp_label.text = "%s>%s" % [attacker.health, max(0, attacker.health - defender_dmg)] if defender_dmg > 0 else str(attacker.health)
	defender_hp_label.text = "%s>%s" % [defender.health, max(0, defender.health - attacker_dmg)] if attacker_dmg > 0 else str(defender.health)
	
	show()

func hide_forecast():
	hide()
