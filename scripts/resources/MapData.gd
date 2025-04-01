extends Resource

class_name MapData

# Map properties
var map_name: String = "Untitled Map"
var map_id: String = "map_001"
var grid_size: Vector2i = Vector2i(16, 16)

# Terrain data
var terrain_data: Array = []

# Unit spawn data
var player_spawn_options: Array = []
var enemy_spawns: Array = []
var ally_spawns: Array = []

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

# Initialize a new map with default terrain
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

# Get terrain at a specific position
func get_terrain(pos: Vector2i) -> String:
	if is_valid_position(pos):
		return terrain_data[pos.x][pos.y]
	return "invalid"

# Check if a position is valid
func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

# Add a player unit spawn
func add_player_spawn(unit_data: Dictionary) -> void:
	player_spawn_options.append(unit_data)

# Add an enemy unit spawn
func add_enemy_spawn(unit_data: Dictionary) -> void:
	enemy_spawns.append(unit_data)

# Add an ally unit spawn
func add_ally_spawn(unit_data: Dictionary) -> void:
	ally_spawns.append(unit_data)

# Set victory condition
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

# Save map data to a file
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

# Load map data from a file
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
		
		map_data.victory_condition = json_result.get("victory_condition", VictoryCondition.DEFEAT_ALL)
		map_data.victory_param = json_result.get("victory_param", 0)
		
		map_data.map_description = json_result.get("map_description", "")
		map_data.map_objective = json_result.get("map_objective", "Defeat all enemies")
	
	return map_data

# Create a sample map for testing
static func create_sample_map() -> MapData:
	var map = MapData.new()
	map.map_name = "Tutorial Battle"
	map.map_id = "tutorial_01"
	map.grid_size = Vector2i(10, 10)
	
	# Initialize with plains
	map.initialize(map.grid_size, "plains")
	
	# Add some forest and mountains
	map.set_terrain(Vector2i(2, 3), "forest")
	map.set_terrain(Vector2i(3, 3), "forest")
	map.set_terrain(Vector2i(2, 4), "forest")
	map.set_terrain(Vector2i(7, 7), "mountains")
	map.set_terrain(Vector2i(8, 7), "mountains")
	
	# Add player spawns
	map.add_player_spawn({
		"unit_class": GameUnit.UnitClass.WARRIOR,
		"position": {"x": 1, "y": 1},
		"level": 1,
		"name": "Hero"
	})
	
	map.add_player_spawn({
		"unit_class": GameUnit.UnitClass.ARCHER,
		"position": {"x": 2, "y": 1},
		"level": 1,
		"name": "Archer"
	})
	
	# Add enemy spawns
	map.add_enemy_spawn({
		"unit_class": GameUnit.UnitClass.WARRIOR,
		"position": {"x": 8, "y": 8},
		"level": 1,
		"name": "Bandit"
	})
	
	map.add_enemy_spawn({
		"unit_class": GameUnit.UnitClass.WARRIOR,
		"position": {"x": 7, "y": 8},
		"level": 1,
		"name": "Bandit"
	})
	
	# Set victory condition
	map.set_victory_condition(VictoryCondition.DEFEAT_ALL)
	
	# Set description
	map.map_description = "A small skirmish to learn the basics of combat."
	
	return map 
