extends Button
class_name MenuActionButton

func _ready():
	focus_mode = Control.FOCUS_ALL  # Ensure button can receive focus

func set_selected(is_selected: bool) -> void:
	if is_selected:
		modulate = Color(1, 1, 0)  # Yellow highlight
	else:
		modulate = Color(1, 1, 1)  # Normal color
