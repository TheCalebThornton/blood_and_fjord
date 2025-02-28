extends Panel
class_name CharacterActionsPanel

@onready var actions_container = $MarginContainer/ActionsContainer

var action_button_scene = preload("res://scenes/ui/action_button.tscn")
var is_open = false

func _ready():
	hide()

func open_actions(character: Character):
	update_ui_with_actions(character)
	
	# Wait one frame to ensure the panel size is updated after adding action buttons
	await get_tree().process_frame
	
	# Find the collision shape to get character dimensions
	var character_size = Vector2(25, 60)  # Default fallback size
	var collision_shape = character.get_node_or_null("CollisionShape2D")
	if collision_shape:
		character_size = collision_shape.shape.get_rect().size
	var panel_size = get_rect().size
	var margin = 10  # Pixels of margin between character and panel
	
	# Default position (to the right of character)
	var new_position = character.global_position + Vector2(character_size.x/2 + margin, -character_size.y/2)
	
	# Get viewport rect to check boundaries
	var viewport_rect = get_viewport_rect().size
	var camera = get_viewport().get_camera_2d()
	var camera_position = camera.global_position if camera else Vector2.ZERO
	var camera_right = camera_position.x + viewport_rect.x/2
	
	# Check if panel would go outside the right edge of the viewport
	if new_position.x + panel_size.x > camera_right:
		# Not enough space on right, position to the left of character instead
		new_position.x = character.global_position.x - panel_size.x - margin - character_size.x/2
	
	# Ensure vertical position is within view
	new_position.y = clamp(new_position.y, 
		camera_position.y - viewport_rect.y/2, 
		camera_position.y + viewport_rect.y/2 - panel_size.y)
	
	position = new_position
	self.is_open = true
	show()

func close_actions():
	hide()

func update_ui_with_actions(character: Character):
	clear_actions()

	for action in character.get_available_actions():
		add_action_button(action, character)

func clear_actions():
	for child in actions_container.get_children():
		child.queue_free()

func add_action_button(action: Action, character: Character):
	var button = action_button_scene.instantiate()
	actions_container.add_child(button)
	button.setup(action, character)
