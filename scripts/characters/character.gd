extends CharacterBody2D
class_name Character

enum CharacterState {IDLE, MOVING_RIGHT, MOVING_LEFT, SELECTED, INACTIVE}

@export var stats: CharacterStats:
	set(value):
		# this allows us to keep the stats unique per Character instance
		stats = value.duplicate() if value else null
@export var grid_position: Vector2i = Vector2i(0,0)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var current_state: CharacterState = CharacterState.IDLE
var actions: CharacterActions
var is_my_turn: bool = false
var selected: bool = false:
	set(value):
		selected = value
		if value:
			set_state(CharacterState.SELECTED)
		elif not value and current_state != CharacterState.INACTIVE:
			set_state(CharacterState.IDLE)
	get():
		return selected
var _color_highlight: Color = Color(1.4, 1.4, 1.4)

func _ready():
	position = GameBoard.grid_to_world(grid_position)
	set_state(CharacterState.IDLE)
	actions = CharacterActions.new(self)

func _mouse_enter():
	if current_state != CharacterState.INACTIVE and not selected and is_my_turn:
		modulate = _color_highlight

func _mouse_exit():
	if current_state != CharacterState.INACTIVE and not selected:
		modulate = Color(1, 1, 1)
	
func set_state(new_state: CharacterState):
	current_state = new_state
	match current_state:
		CharacterState.IDLE:
			modulate = Color(1, 1, 1)
			if sprite:
				sprite.play("idle")
				
		CharacterState.MOVING_RIGHT:
			modulate = _color_highlight
			if sprite:
				sprite.flip_h = false
				sprite.play("move_right")
				
		CharacterState.MOVING_LEFT:
			modulate = _color_highlight
			if sprite:
				sprite.flip_h = true
				# Moving right but flipped
				sprite.play("move_right")
		
		CharacterState.SELECTED:
			modulate = _color_highlight
			sprite.play("selected")
			
		CharacterState.INACTIVE:
			modulate = Color(0.5, 0.5, 0.5)
			sprite.stop()

func spawn_at(grid_pos: Vector2i):
	grid_position = grid_pos
	var target_pos = GameBoard.grid_to_world(grid_pos)
	set_state(CharacterState.IDLE)
	position = target_pos

func move_to(new_grid_pos: Vector2i, animate: bool = true):
	var target_pos = GameBoard.grid_to_world(new_grid_pos)
	
	if animate == true:
		if new_grid_pos.x > grid_position.x:
			set_state(CharacterState.MOVING_RIGHT)
		elif new_grid_pos.x < grid_position.x:
			set_state(CharacterState.MOVING_LEFT)
		
		# Set move speed to 5 grids per second
		var grid_distance = (new_grid_pos - grid_position).length()
		var duration = grid_distance / 3.0
		
		var tween = create_tween()
		tween.tween_property(self, "position", target_pos, duration)
		tween.finished.connect(func(): 
			if selected:
				set_state(CharacterState.SELECTED)
			else:
				set_state(CharacterState.IDLE)
			open_actions_menu()
			grid_position = new_grid_pos
			
		)
	else:
		position = target_pos
		grid_position = new_grid_pos
		
		if selected:
			set_state(CharacterState.SELECTED)
		else:
			set_state(CharacterState.IDLE)
		open_actions_menu()
	actions.use_move()

func open_actions_menu():
	var action_panel: CharacterActionsPanel = get_parent().get_node("CharacterActionsPanel")
	if action_panel:
		action_panel.open_actions(self)
	
func close_actions_menu():
	var action_panel: CharacterActionsPanel = get_parent().get_node("CharacterActionsPanel")
	if action_panel: 
		action_panel.close_actions()

func get_valid_move_positions() -> Array[Vector2i]:
	var valid_positions: Array[Vector2i] = []
	var movement_range = stats.movement
	
	# Check all positions within movement range
	for x in range(-movement_range, movement_range + 1):
		for y in range(-movement_range, movement_range + 1):
			var check_pos = grid_position + Vector2i(x, y)
			# Manhattan distance for movement (diamond grid)
			if abs(x) + abs(y) <= movement_range:
				valid_positions.append(check_pos)
	
	return valid_positions 

func get_available_actions() -> Array[Action]:
	return actions.get_available_actions()

func select():
	selected = true
	EventBus.character_selected.emit(self)

func deselect():
	selected = false
	EventBus.character_deselected.emit(self)

func reset_action_tracking():
	actions.reset()
	set_state(CharacterState.IDLE)
