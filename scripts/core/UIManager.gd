extends CanvasLayer
class_name UIManager

var colors = {
	"player": Color(0.2, 0.6, 1.0),
	"enemy": Color(1.0, 0.2, 0.2),
	"ally": Color(0.2, 0.8, 0.2)
}

var factionDisplayConfig = {
	GameUnit.Faction.PLAYER: {
		"labelText": "Player's Turn",
		"color": colors.get("player")
	},
	GameUnit.Faction.ENEMY: {
		"labelText": "Enemy's Turn",
		"color": colors.get("enemy")
	},
	GameUnit.Faction.ALLY: {
		"labelText": "Ally's Turn",
		"color": colors.get("ally")
	}
}

@onready var announcement_label: RichTextLabel = $Announcement

func display_announcement():
	announcement_label.show()
	await get_tree().create_timer(2.0).timeout 
	announcement_label.hide()

func announce_faction_turn(faction: GameUnit.Faction):
	# Convert color to hex format for BBCode
	var color_hex = factionDisplayConfig[faction].color.to_html(false)
	announcement_label.bbcode_enabled = true
	announcement_label.text = "[color=#" + color_hex + "]" + factionDisplayConfig[faction].labelText + "[/color]"
	display_announcement()
	
func announce_level_end(victory: bool = false):
	# Convert color to hex format for BBCode
	var color_hex = colors.get("player") if victory else colors.get("enemy")
	var text = "Victory!" if victory else "Defeat!"
	announcement_label.bbcode_enabled = true
	announcement_label.text = "[color=#" + color_hex.to_html(false) + "]" + text
	display_announcement()
