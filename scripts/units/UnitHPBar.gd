extends Control
class_name UnitHPBar

@onready var progress_bar = $ProgressBar

var faction_colors = {
	GameUnit.Faction.PLAYER: Color(0.2, 0.6, 1.0),
	GameUnit.Faction.ENEMY: Color(1.0, 0.2, 0.2),
	GameUnit.Faction.ALLY: Color(0.2, 0.8, 0.2)
}

func _ready():
	# Make sure the HP bar is always visible on top of other elements
	top_level = true

func update_health(current: int, maximum: int, faction: int = GameUnit.Faction.PLAYER):
	progress_bar.max_value = maximum
	progress_bar.value = current
	
	# Update the fill color based on faction
	var style = StyleBoxFlat.new()
	style.bg_color = faction_colors.get(faction, Color(0, 1, 0))
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	progress_bar.add_theme_stylebox_override("fill", style)

func _process(_delta):
	# If this is a child of a unit, update position to stay below it
	if get_parent() is GameUnit:
		# Update the global position to be just below the unit sprite
		global_position = get_parent().global_position + Vector2(-16, 20)
