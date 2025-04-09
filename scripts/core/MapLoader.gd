extends Node2D

class_name MapLoader

@onready var grid_system: GridSystem = $"../GridSystem"
@onready var unit_manager: UnitManager = $"../UnitManager"
@onready var item_manager: ItemManager = $"../ItemManager"
var current_map: MapData = null

var terrain_scenes: Dictionary = {
	"plains": preload("res://scenes/terrain/Plains.tscn"),
	"forest": preload("res://scenes/terrain/Forest.tscn"),
	"mountains": preload("res://scenes/terrain/Mountains.tscn"),
	"water": preload("res://scenes/terrain/Water.tscn"),
	"wall": preload("res://scenes/terrain/Wall.tscn")
}

var terrain_node: Node2D
var units_node: Node2D
var items_node: Node2D
func _ready():
	terrain_node = get_node("/root/Main/Terrain")
	units_node = get_node("/root/Main/Units")
	items_node = get_node("/root/Main/Items")

func load_map(map_path: String, player_units: Array[UnitData]) -> bool:
	var map_data = MapData.load_from_file(map_path)
	
	if not map_data:
		return false
	
	return initialize_map(map_data, player_units)

func initialize_map(map_data: MapData, player_units: Array[UnitData]) -> bool:
	clear_map()
	current_map = map_data
	
	grid_system.initialize_grid(map_data.grid_size)
	create_terrain()
	spawn_units(player_units)
	spawn_items()
	
	return true

func clear_map() -> void:
	for child in terrain_node.get_children():
		child.queue_free()
	
	for child in units_node.get_children():
		child.queue_free()
	
	grid_system.reset()
	unit_manager.reset()

func create_terrain() -> void:
	if not current_map:
		return
	
	# Create terrain instances
	for x in range(current_map.grid_size.x):
		for y in range(current_map.grid_size.y):
			var pos = Vector2i(x, y)
			var terrain_type = current_map.get_terrain(pos)
			
			grid_system.set_terrain_at(pos, terrain_type)
			
			# Create visual representation
			if terrain_scenes.has(terrain_type):
				var terrain_scene = terrain_scenes[terrain_type]
				var terrain_instance = terrain_scene.instantiate()
				
				terrain_instance.position = grid_system.grid_to_world(pos)
				terrain_node.add_child(terrain_instance)

func spawn_units(player_unit_data: Array[UnitData]) -> void:
	if not current_map:
		return
	
	for player_unit in player_unit_data:
		spawn_player_unit(current_map.player_spawn_options, player_unit)
	for spawn_data in current_map.enemy_spawns:
		spawn_unit(spawn_data, GameUnit.Faction.ENEMY)
	for spawn_data in current_map.ally_spawns:
		spawn_unit(spawn_data, GameUnit.Faction.ALLY)

func spawn_player_unit(spawn_options: Array, player_unit: UnitData):
	var available_spawns = spawn_options.filter(func(pos_data): 
		var grid_pos = Vector2i(int(pos_data.x), int(pos_data.y))
		return not unit_manager.get_unit_at(grid_pos)
	)
	
	if available_spawns.is_empty():
		print("No available spawn positions for player unit!")
		return
	
	var unit_factory = UnitFactory.new()
	var unit_instance = unit_factory.create_unit(player_unit, GameUnit.Faction.PLAYER)
	
	if unit_instance:
		var pos_data = available_spawns[0]
		var grid_pos = Vector2i(int(pos_data.x), int(pos_data.y))
		unit_instance.grid_position = grid_pos
		unit_instance.position = grid_system.grid_to_world_centered(grid_pos)
		units_node.add_child(unit_instance)
		unit_manager.add_unit(unit_instance)

func spawn_unit(spawn_data: Dictionary, faction: int) -> GameUnit:
	var unit = spawn_data.get("unit")
	var unit_data = UnitData.new(
		spawn_data.get("name", "Unit"),
		GameUnit.UnitClass.keys().find(unit.get("class", "WARRIOR").to_upper()),
		unit.get("sprite", "Blue"),
		spawn_data.get("level", 1)
	)
	
	var unit_factory = UnitFactory.new()
	var unit_instance = unit_factory.create_unit(unit_data, faction)
	
	# TODO Update this logic for map data having 'spawn locations' then assiging units from a player.json to an available position
	if unit_instance:
		var pos_data = spawn_data.get("position", {"x": 0, "y": 0})
		var grid_pos = Vector2i(pos_data.x, pos_data.y)
		unit_instance.grid_position = grid_pos
		unit_instance.position = grid_system.grid_to_world_centered(grid_pos)
		units_node.add_child(unit_instance)
		unit_manager.add_unit(unit_instance)
	
	return unit_instance

func spawn_items() -> void:
	if not current_map:
		return
	
	for i in range(current_map.item_spawn_data.item_count):
		var item_spawn_options = current_map.item_spawn_data.spawn_options
		var available_spawns = item_spawn_options.filter(func(pos_data):
			var grid_pos = Vector2i(int(pos_data.x), int(pos_data.y))
			return not unit_manager.get_unit_at(grid_pos) and not item_manager.get_item_at(grid_pos)
		)

		if available_spawns.is_empty():
			print("No available spawn positions for item!")
			continue
		
		var item_instance = MapItem.new(current_map.item_spawn_data.available_items[i])
		item_instance.grid_position = available_spawns[0]
		item_instance.position = grid_system.grid_to_world_centered(available_spawns[0])
		items_node.add_child(item_instance)
		item_manager.add_item(item_instance)
		
		
func get_victory_condition() -> String:
	if current_map:
		return current_map.map_objective
	return "Defeat all enemies"

func check_victory_condition() -> bool:
	if not current_map:
		return false
	
	match current_map.victory_condition:
		MapData.VictoryCondition.DEFEAT_ALL:
			return unit_manager.is_faction_defeated(GameUnit.Faction.ENEMY)
		MapData.VictoryCondition.DEFEAT_COMMANDER:
			# Would need to implement commander tracking
			return false
		MapData.VictoryCondition.SURVIVE_TURNS:
			# Would need to implement turn counting
			return false
		MapData.VictoryCondition.ESCAPE:
			# Would need to implement escape points
			return false
		MapData.VictoryCondition.SEIZE_POINT:
			# Would need to implement seize points
			return false
	
	return false 
