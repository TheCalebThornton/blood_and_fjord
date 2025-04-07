extends PanelContainer
class_name NewGameView

signal start_new_game(units: Array[UnitData])

@onready var selection_grid: ArmySelection = $MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/GridContainer
@onready var description: RichTextLabel = $MarginContainer/VBoxContainer/DescriptionContainer/Description
@onready var audio_manager = $"/root/Main/GameManager/AudioManager"

var current_action_index: int = 0
var menu_buttons: Array = []

func _ready():
	hide()

func show_menu() -> void:
	await selection_grid.init_armies()
	menu_buttons = []
	for child in selection_grid.get_children():
		menu_buttons.append(child)
	_update_selection(0, true)
	show()
	
func select_next_action(deltaVector: Vector2i) -> void:
	var next_index = current_action_index
	if (deltaVector == Vector2i(1, 0)):
		next_index += 1
	elif (deltaVector == Vector2i(0, 1)):
		next_index += selection_grid.columns
	elif (deltaVector == Vector2i(-1, 0)):
		next_index -= 1
	elif (deltaVector == Vector2i(0, -1)):
		next_index -= selection_grid.columns
		
	next_index = clampi(next_index, 0, menu_buttons.size() - 1)
	_update_selection(next_index)
	
func _update_selection(new_index: int, is_init: bool = false) -> void:
	if menu_buttons.size()-1 < new_index or new_index < 0:
		return
	current_action_index = new_index
	for i in range(menu_buttons.size()):
		_set_menu_button_selected(i, i == current_action_index)
	var active_btn = menu_buttons[current_action_index]
	if not is_init: audio_manager.play_ui_sound("button_focus")

	# TODO Refactor this to use separate textFields instead of phony spacing
	var desc_text = ""
	if menu_buttons[current_action_index].is_unlocked:
		desc_text = "[b]Unit Overview:[b]\n"
		for unit in active_btn.army.units:
			desc_text += "[b]%s[/b]\t\t" % unit.unit_name
			desc_text += "Class: %s\t\t" % GameUnit.UnitClass.keys()[unit.unit_class]
			desc_text += "Level: %d\n" % unit.level
	else:
		desc_text = "???"
	description.text = desc_text
	

func _set_menu_button_selected(index: int, selected: bool) -> void:
	if selected:
		menu_buttons[index].modulate = Color(1, 1, 0)  # Yellow highlight
	else:
		menu_buttons[index].modulate = Color(1, 1, 1)  # Normal color

func confirm_selection() -> void:
	if menu_buttons[current_action_index].is_unlocked:
		start_new_game.emit(menu_buttons[current_action_index].army.units)
		audio_manager.play_ui_sound("button_click")
