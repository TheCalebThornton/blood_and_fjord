extends Node2D
class_name FloatingText

enum TextType {
	DAMAGE,
	HEAL,
	MISS,
	CRITICAL
}

var text: String
var type: TextType
var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 3.0

@onready var label: Label = $Label

func _ready():
	var tween = create_tween()
	match type:
		TextType.DAMAGE:
			label.modulate = Color(1, 0.2, 0.2)  # Red for damage
			label.add_theme_font_size_override("font_size", 64)
		TextType.HEAL:
			label.modulate = Color(0.2, 1, 0.2)  # Green for healing
			label.add_theme_font_size_override("font_size", 64)
		TextType.MISS:
			label.modulate = Color(0.8, 0.8, 0.8)  # Gray for misses
			label.add_theme_font_size_override("font_size", 64)
		TextType.CRITICAL:
			label.modulate = Color(1, 0.8, 0)  # Gold for criticals
			label.add_theme_font_size_override("font_size", 84)
			# Add a scale animation for critical hits
			tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
	
	label.text = text
	# Set up the floating animation
	tween.tween_property(self, "position:y", position.y - 70, lifetime)
	tween.parallel().tween_property(self, "modulate:a", 0.0, lifetime)
	tween.tween_callback(queue_free)
	
