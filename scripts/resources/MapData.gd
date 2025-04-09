extends Resource
class_name MapData

class ItemSpawnData:
	var item_count: int = 0
	var spawn_options: Array = []
	var available_items: Array = []

# Map properties
var map_name: String = "Untitled Map"
var map_id: String = "map_001"
var grid_size: Vector2i = Vector2i(16, 16)

# Terrain data
var terrain_data: Array = []

# Spawn data
var player_spawn_options: Array = []
var enemy_spawns: Array = []
var ally_spawns: Array = []
var item_spawn_data: ItemSpawnData = ItemSpawnData.new()

# Victory conditions
enum VictoryCondition {
	DEFEAT_ALL,
	DEFEAT_COMMANDER,
	SURVIVE_TURNS,
	ESCAPE,
	SEIZE_POINT
}

var victory_condition: int = VictoryCondition.DEFEAT_ALL
var victory_param: int = 0  # Used for turns to survive or target unit ID

# Map objectives and description
var map_description: String = ""
var map_objective: String = "Defeat all enemies"

func initialize(size: Vector2i, default_terrain: String = "plains") -> void:
	grid_size = size
	terrain_data.resize(size.x)
	
	for x in range(size.x):
		terrain_data[x] = []
		terrain_data[x].resize(size.y)
		
		for y in range(size.y):
			terrain_data[x][y] = default_terrain

func set_terrain(pos: Vector2i, terrain_type: String) -> void:
	if is_valid_position(pos):
		terrain_data[pos.x][pos.y] = terrain_type

func get_terrain(pos: Vector2i) -> String:
	if is_valid_position(pos):
		return terrain_data[pos.x][pos.y]
	return "invalid"

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

func add_player_spawn(unit_data: Dictionary) -> void:
	player_spawn_options.append(unit_data)

func add_enemy_spawn(unit_data: Dictionary) -> void:
	enemy_spawns.append(unit_data)

func add_ally_spawn(unit_data: Dictionary) -> void:
	ally_spawns.append(unit_data)

func set_victory_condition(condition: int, param: int = 0) -> void:
	victory_condition = condition
	victory_param = param
	
	# Update objective text based on condition
	match condition:
		VictoryCondition.DEFEAT_ALL:
			map_objective = "Defeat all enemies"
		VictoryCondition.DEFEAT_COMMANDER:
			map_objective = "Defeat the enemy commander"
		VictoryCondition.SURVIVE_TURNS:
			map_objective = "Survive for %d turns" % param
		VictoryCondition.ESCAPE:
			map_objective = "Escape with all units"
		VictoryCondition.SEIZE_POINT:
			map_objective = "Seize the target point"

# TODO not used yet - not sure if I want to allow in progress map loading
func save_to_file(path: String) -> Error:
	var map_dict = {
		"map_name": map_name,
		"map_id": map_id,
		"grid_size": {"x": grid_size.x, "y": grid_size.y},
		"terrain_data": terrain_data,
		"player_spawn_options": player_spawn_options,
		"enemy_spawns": enemy_spawns,
		"ally_spawns": ally_spawns,
		"victory_condition": victory_condition,
		"victory_param": victory_param,
		"map_description": map_description,
		"map_objective": map_objective
	}
	
	var json_string = JSON.stringify(map_dict, "\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file:
		file.store_string(json_string)
		return OK
	
	return ERR_CANT_OPEN

static func load_from_file(path: String) -> MapData:
	var map_data = MapData.new()
	
	if not FileAccess.file_exists(path):
		return map_data
	
	var file = FileAccess.open(path, FileAccess.READ)
	
	if not file:
		return map_data
	
	var json_string = file.get_as_text()
	var json_result = JSON.parse_string(json_string)
	
	if json_result is Dictionary:
		map_data.map_name = json_result.get("map_name", "Untitled Map")
		map_data.map_id = json_result.get("map_id", "map_001")
		
		map_data.terrain_data = json_result.get("terrain_data", [])
		map_data.grid_size = Vector2i(map_data.terrain_data.size(), map_data.terrain_data[0].size())
		map_data.player_spawn_options = json_result.get("player_spawn_options", [])
		map_data.enemy_spawns = json_result.get("enemy_spawns", [])
		map_data.ally_spawns = json_result.get("ally_spawns", [])
		var items_dict = json_result.get("items", {})
		map_data.item_spawn_data.item_count = items_dict.get("item_count", 0)
		map_data.item_spawn_data.spawn_options = items_dict.get("spawn_options", [])
		map_data.item_spawn_data.available_items = items_dict.get("available_items", [])
		
		map_data.victory_condition = json_result.get("victory_condition", VictoryCondition.DEFEAT_ALL)
		map_data.victory_param = json_result.get("victory_param", 0)
		
		map_data.map_description = json_result.get("map_description", "")
		map_data.map_objective = json_result.get("map_objective", "Defeat all enemies")
	
	return map_data
