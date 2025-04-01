extends PanelContainer
class_name NewGameView

signal start_new_game(units: Array[UnitData])

@onready var selection_grid: GridContainer = $MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/GridContainer
@onready var description: RichTextLabel = $MarginContainer/VBoxContainer/DescriptionContainer/Description

var current_action_index: int = 0
var menu_buttons: Array[ArmySelection] = []

func _ready():
	menu_buttons = []
	for child in selection_grid.get_children():
		if child is ArmySelection:
			menu_buttons.append(child)
	
	hide()

func show_menu() -> void:
	_update_selection(0)
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
	
func _update_selection(new_index: int) -> void:
	current_action_index = new_index
	for i in range(menu_buttons.size()):
		menu_buttons[i].set_selected(i == current_action_index)
	var active_btn = menu_buttons[current_action_index]
	active_btn.grab_focus()
	
	# TODO Refactor this to use separate textFields instead of phony spacing
	var desc_text = "[b]Unit Overview:[b]\n"
	for unit in active_btn.units:
		if unit:
			desc_text += "[b]%s[/b]\t\t" % unit.unit_name
			desc_text += "Class: %s\t\t" % GameUnit.UnitClass.keys()[unit.unit_class]
			desc_text += "Level: %d\n" % unit.level
	
	description.text = desc_text

func confirm_selection() -> void:
	start_new_game.emit(menu_buttons[current_action_index].units)
