extends Button
class_name MenuActionButton

@onready var audio_manager = $"/root/Main/GameManager/AudioManager"

func _ready():
	focus_mode = Control.FOCUS_ALL  # Ensure button can receive focus
	pressed.connect(_on_pressed)

func _on_focus_entered() -> void:
	audio_manager.play_ui_sound("button_hover")

func _on_pressed() -> void:
	audio_manager.play_ui_sound("button_click")

func set_selected(is_selected: bool, suppress_audio: bool = false) -> void:
	if is_selected:
		modulate = Color(1, 1, 0)  # Yellow highlight
		if !suppress_audio: _on_focus_entered()
	else:
		modulate = Color(1, 1, 1)  # Normal color
