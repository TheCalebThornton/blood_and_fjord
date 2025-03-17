extends Control
class_name UnitActionMenu

signal action_selected(action_id: String)
signal menu_closed()

@onready var button_container = $MarginContainer/VBoxContainer

var action_button_scene = preload("res://scenes/ui/UnitActionButton.tscn")
var current_action_index: int = 0
var action_buttons: Array = []

func _ready():
	hide()

func show_actions(actions: Array[Dictionary]) -> void:
	# Clear existing buttons
	for child in button_container.get_children():
		child.queue_free()
	action_buttons.clear()
	current_action_index = 0
	
	# TODO should implement logic to only show actions that are able to be used.
	for action in actions:
		var button = action_button_scene.instantiate()
		button.text = action["name"]
		button.pressed.connect(func(): _on_action_button_pressed(action["id"]))
		button.focus_entered.connect(func(): _on_button_focused(button))
		button_container.add_child(button)
		action_buttons.append(button)
	
	if not action_buttons.is_empty():
		_update_selection(0)
	
	await get_tree().process_frame
	show()
	
func select_next_action() -> void:
	if action_buttons.is_empty():
		return
		
	var next_index = (current_action_index + 1) % action_buttons.size()
	_update_selection(next_index)

func select_previous_action() -> void:
	if action_buttons.is_empty():
		return
		
	var prev_index = current_action_index - 1
	if prev_index < 0:
		prev_index = action_buttons.size() - 1
	_update_selection(prev_index)

func _update_selection(new_index: int) -> void:
	current_action_index = new_index
	for i in range(action_buttons.size()):
		action_buttons[i].set_selected(i == current_action_index)
	action_buttons[current_action_index].grab_focus()

func _on_button_focused(button: Button) -> void:
	var index = action_buttons.find(button)
	if index != -1 and index != current_action_index:
		_update_selection(index)

func confirm_selection() -> void:
	if not action_buttons.is_empty():
		action_buttons[current_action_index].emit_signal("pressed")

func _on_action_button_pressed(action_id: String) -> void:
	action_selected.emit(action_id)
	hide()

func close() -> void:
	# Remove focus before hiding
	if has_focus():
		release_focus()
	for button in action_buttons:
		if button.has_focus():
			button.release_focus()
			
	hide()
	menu_closed.emit()
	# Clear the buttons when closing
	for child in button_container.get_children():
		child.queue_free()
	action_buttons.clear()
	current_action_index = 0
	
