extends Control
class_name UnitActionMenu

signal action_selected(action_id: String)
signal menu_closed()

@onready var button_container = $MarginContainer/VBoxContainer

var action_button_scene = preload("res://scenes/ui/UnitActionButton.tscn")

func _ready():
	hide()

func show_actions(actions: Array[Dictionary]) -> void:
	# Clear existing buttons
	for child in button_container.get_children():
		child.queue_free()
	
	for action in actions:
		var button = action_button_scene.instantiate()
		button.text = action["name"]
		button.pressed.connect(func(): _on_action_button_pressed(action["id"]))
		button_container.add_child(button)
	await get_tree().process_frame
	show()

func _on_action_button_pressed(action_id: String) -> void:
	action_selected.emit(action_id)
	hide()

func close() -> void:
	hide()
	menu_closed.emit()
	
