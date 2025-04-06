extends PanelContainer
class_name BattleMenu

enum MenuActions {
	QuitToMenu,
	Surrender,
	EndTurn
}

signal battle_menu_action(action: MenuActions)
signal menu_closed()

@onready var quit_to_menu_btn = $MarginContainer/VBoxContainer/QuitToMenu
@onready var surrender_btn = $MarginContainer/VBoxContainer/Surrender
@onready var end_turn_btn = $MarginContainer/VBoxContainer/EndTurn

var current_action_index: int = 0
var menu_buttons: Array[MenuActionButton] = []

func _ready():
	quit_to_menu_btn.pressed.connect(func(): _on_menu_action_pressed(MenuActions.QuitToMenu))
	quit_to_menu_btn.focus_entered.connect(func(): _on_button_focused(quit_to_menu_btn))
	surrender_btn.pressed.connect(func(): _on_menu_action_pressed(MenuActions.Surrender))
	surrender_btn.focus_entered.connect(func(): _on_button_focused(surrender_btn))
	end_turn_btn.pressed.connect(func(): _on_menu_action_pressed(MenuActions.EndTurn))
	end_turn_btn.focus_entered.connect(func(): _on_button_focused(end_turn_btn))
	menu_buttons = [quit_to_menu_btn, surrender_btn, end_turn_btn]
	hide()

func show_battle_menu() -> void:
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
	for i in range(menu_buttons.size()):
		menu_buttons[i].set_selected(i == current_action_index, is_init)
	menu_buttons[current_action_index].grab_focus()

func _on_button_focused(button: Button) -> void:
	var index = menu_buttons.find(button)
	if index != -1 and index != current_action_index:
		_update_selection(index)

func confirm_selection() -> void:
	menu_buttons[current_action_index].emit_signal("pressed")

func _on_menu_action_pressed(action: MenuActions) -> void:
	battle_menu_action.emit(action)
	hide()
	
