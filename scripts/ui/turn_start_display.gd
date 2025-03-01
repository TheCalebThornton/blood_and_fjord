class_name TurnStartDisplay
extends RichTextLabel

var factionDisplayConfig = {
	Faction.FACTION_ENUM.PLAYER: {
		"labelText": "Player's Turn",
		"color": Color(0.2, 0.6, 1.0)
	},
	Faction.FACTION_ENUM.ENEMY: {
		"labelText": "Enemy's Turn",
		"color": Color(1.0, 0.2, 0.2)
	},
	Faction.FACTION_ENUM.OTHER: {
		"labelText": "Other's Turn",
		"color": Color(0.2, 0.8, 0.2)
	}
	# Add more factions as needed
}

func _init() -> void:
	EventBus.faction_turn_changed.connect(showTurnStart)

func showTurnStart(faction: Faction):
	var factionEnum = faction.value
	if factionDisplayConfig.has(factionEnum):
		var config = factionDisplayConfig[factionEnum]
		setTextAndColor(config["labelText"], config["color"])
		show()
		await get_tree().create_timer(2.0).timeout
		hide()
	else:
		push_error("Unknown faction enum: " + str(factionEnum))

func setTextAndColor(val: String, color: Color):
	# Convert color to hex format for BBCode
	var color_hex = color.to_html(false)
	bbcode_enabled = true
	text = "[color=#" + color_hex + "]" + val + "[/color]"
	
