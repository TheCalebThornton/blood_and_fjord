extends Node2D
class_name Character

@export var stats: CharacterStats:
	set(value):
		# this allows us to keep the stats unique per Character instance
		stats = value.duplicate() if value else null
@export var grid_position: Vector2i = Vector2i(0,0)
var _color_highlight: Color = Color(1.4, 1.4, 1.4)
var _selected: bool = false


func _ready():
	position = GameBoard.grid_to_world(grid_position)

func move_to(new_grid_pos: Vector2i, animate: bool = true):
	grid_position = new_grid_pos
	var target_pos = GameBoard.grid_to_world(new_grid_pos)
	
	if animate == true:
		create_tween().tween_property(self, "position", target_pos, 0.3)
	else:
		position = target_pos


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

func _mouse_enter():
	if not _selected:
		modulate = _color_highlight

func _mouse_exit():
	if not _selected:
		modulate = Color(1, 1, 1)

func select():
	_selected = true
	modulate = _color_highlight
	EventBus.character_selected.emit(self)

func deselect():
	_selected = false
	modulate = Color(1, 1, 1)
	EventBus.character_deselected.emit(self)
