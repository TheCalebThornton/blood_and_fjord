extends PanelContainer
class_name HomeView

enum MenuActions {
	NEW_GAME,
	RESUME,
	UNLOCKABLES,
	CLASS_INFO
}

signal home_menu_action(action: MenuActions)
signal menu_closed()

@onready var new_game_btn: Button = $MarginContainer/VBoxContainer/ButtonsMargin/PanelContainer/VBoxContainer/NewGame
@onready var resume_btn: Button = $MarginContainer/VBoxContainer/ButtonsMargin/PanelContainer/VBoxContainer/Resume
@onready var unlockables_btn: Button = $MarginContainer/VBoxContainer/ButtonsMargin/PanelContainer/VBoxContainer/Unlockables
@onready var class_info_btn: Button = $MarginContainer/VBoxContainer/ButtonsMargin/PanelContainer/VBoxContainer/ClassInfo
@onready var audio_manager = $"/root/Main/GameManager/AudioManager"

var current_action_index: int = 0
var menu_buttons: Array[Button] = []

func _ready():
	new_game_btn.pressed.connect(func(): _on_menu_action_pressed(MenuActions.NEW_GAME))
	new_game_btn.focus_entered.connect(func(): _on_button_focused(new_game_btn))
	resume_btn.pressed.connect(func(): _on_menu_action_pressed(MenuActions.RESUME))
	resume_btn.focus_entered.connect(func(): _on_button_focused(resume_btn))
	unlockables_btn.pressed.connect(func(): _on_menu_action_pressed(MenuActions.UNLOCKABLES))
	unlockables_btn.focus_entered.connect(func(): _on_button_focused(unlockables_btn))
	class_info_btn.pressed.connect(func(): _on_menu_action_pressed(MenuActions.CLASS_INFO))
	class_info_btn.focus_entered.connect(func(): _on_button_focused(class_info_btn))
	menu_buttons = [new_game_btn, resume_btn, unlockables_btn, class_info_btn]
	
	hide()

func show_menu() -> void:
	_update_selection(0, true)
	show()
	
func hide_battle_menu() -> void:
	hide()
	menu_closed.emit()
	current_action_index = 0
	
func select_next_action() -> void:
	var next_index = (current_action_index + 1) % menu_buttons.size()
	_update_selection(next_index)

func select_previous_action() -> void:
	var prev_index = current_action_index - 1
	if prev_index < 0:
		prev_index = menu_buttons.size() - 1
	_update_selection(prev_index)

func _update_selection(new_index: int, is_init: bool = false) -> void:
	current_action_index = new_index
	menu_buttons[current_action_index].grab_focus()
	if not is_init: audio_manager.play_ui_sound("button_focus")
	

func _on_button_focused(button: Button) -> void:
	var index = menu_buttons.find(button)
	if index != -1 and index != current_action_index:
		_update_selection(index)

func confirm_selection() -> void:
	menu_buttons[current_action_index].emit_signal("pressed")
	audio_manager.play_ui_sound("button_click")

func _on_menu_action_pressed(action: MenuActions) -> void:
	match action:
		MenuActions.NEW_GAME:
			home_menu_action.emit(action)
		MenuActions.RESUME:
			# TODO Check for saved progress file
			home_menu_action.emit(action)
		MenuActions.UNLOCKABLES:
			pass
		MenuActions.CLASS_INFO:
			pass
