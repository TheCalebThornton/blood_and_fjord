extends Control
class_name BattleUIContainer

@onready var action_menu: UnitActionMenu = $Panel/MarginContainer/UnitActionMenu
@onready var battle_forcast: BattleForecast = $Panel/MarginContainer/BattleForecast
@onready var unit_overview_ui: UnitOverviewUI = $Panel/MarginContainer/UnitOverviewUI
@onready var child_margin_container: MarginContainer = $Panel/MarginContainer
@onready var child_panel: Panel = $Panel
@onready var grid_cursor: GridCursor = $"../../../Cursor"
@onready var grid_system: GridSystem = $"../../GridSystem"

var last_cursor_pos: Vector2

func _ready():
	unit_overview_ui.visibility_changed.connect(_on_child_visibility_changed)
	action_menu.visibility_changed.connect(_on_child_visibility_changed)
	battle_forcast.visibility_changed.connect(_on_child_visibility_changed)
	grid_cursor.cursor_moved.connect(_update_position)
	
func hide_all_ui() -> void:
	unit_overview_ui.hide_unit_stats()
	action_menu.hide_actions()
	battle_forcast.hide_forecast()

func _update_position(cursor_pos: Vector2) -> void:
	last_cursor_pos = grid_system.grid_to_world_centered(cursor_pos)
	_update_container_position()

func _on_child_visibility_changed() -> void:
	# Wait a frame for size calculations to update
	await get_tree().process_frame
	_update_container_position()

func _update_container_position() -> void:
	await get_tree().process_frame
	var viewport_size = get_viewport().size
	
	# If cursor is on right half of screen, anchor to left
	if last_cursor_pos.x > viewport_size.x / 2:
		position.x = 0
	else:
		position.x = viewport_size.x - (size.x + child_panel.size.x + child_margin_container.size.x)
