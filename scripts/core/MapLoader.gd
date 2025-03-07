extends Node2D

class_name MapLoader

# References to other systems
var game_manager: GameManager
@onready var grid_system: GridSystem = $"../GridSystem"
@onready var unit_manager: UnitManager = $"../UnitManager"

# Current map data
var current_map: MapData = null

# Terrain scene references
var terrain_scenes: Dictionary = {
	"plains": preload("res://scenes/terrain/Plains.tscn"),
	#"forest": preload("res://scenes/terrain/Forest.tscn"),
	#"mountains": preload("res://scenes/terrain/Mountains.tscn"),
	#"water": preload("res://scenes/terrain/Water.tscn"),
	#"wall": preload("res://scenes/terrain/Wall.tscn")
}

# Unit scene references
var unit_scenes: Dictionary = {
	Unit.UnitClass.WARRIOR: preload("res://scenes/units/Warrior.tscn"),
	#Unit.UnitClass.ARCHER: preload("res://scenes/units/Archer.tscn"),
	#Unit.UnitClass.MAGE: preload("res://scenes/units/Mage.tscn"),
	#Unit.UnitClass.HEALER: preload("res://scenes/units/Healer.tscn"),
	#Unit.UnitClass.CAVALRY: preload("res://scenes/units/Cavalry.tscn"),
	#Unit.UnitClass.FLIER: preload("res://scenes/units/Flier.tscn")
}

# Node references for organizing instances
var terrain_node: Node2D
var units_node: Node2D

func _ready():
	# Get references to other systems
	game_manager = get_parent()
	
	# Get node references
	terrain_node = get_node("/root/Main/Terrain")
	units_node = get_node("/root/Main/Units")

# Load a map from file
func load_map(map_path: String) -> bool:
	var map_data = MapData.load_from_file(map_path)
	
	if not map_data:
		return false
	
	return initialize_map(map_data)

# Load a sample map for testing
func load_sample_map() -> bool:
	var map_data = MapData.create_sample_map()
	return initialize_map(map_data)

# Initialize the map with the provided data
func initialize_map(map_data: MapData) -> bool:
	# Clear existing map
	clear_map()
	
	# Store current map
	current_map = map_data
	
	# Initialize grid system
	grid_system.initialize_grid(map_data.grid_size)
	
	# Create terrain
	create_terrain()
	
	# Spawn units
	spawn_units()
	
	return true

# Clear the current map
func clear_map() -> void:
	# Clear terrain
	for child in terrain_node.get_children():
		child.queue_free()
	
	# Clear units
	for child in units_node.get_children():
		child.queue_free()
	
	# Reset managers
	grid_system.reset()
	unit_manager.reset()

# Create terrain based on map data
func create_terrain() -> void:
	if not current_map:
		return
	
	# Create terrain instances
	for x in range(current_map.grid_size.x):
		for y in range(current_map.grid_size.y):
			var pos = Vector2i(x, y)
			var terrain_type = current_map.get_terrain(pos)
			
			# Set terrain in grid system
			grid_system.set_terrain_at(pos, terrain_type)
			
			# Create visual representation
			if terrain_scenes.has(terrain_type):
				var terrain_scene = terrain_scenes[terrain_type]
				var terrain_instance = terrain_scene.instantiate()
				
				terrain_instance.position = grid_system.grid_to_world(pos)
				terrain_node.add_child(terrain_instance)

# Spawn units based on map data
func spawn_units() -> void:
	if not current_map:
		return
	
	# Spawn player units
	for spawn_data in current_map.player_spawns:
		spawn_unit(spawn_data, Unit.Faction.PLAYER)
	
	# Spawn enemy units
	for spawn_data in current_map.enemy_spawns:
		spawn_unit(spawn_data, Unit.Faction.ENEMY)
	
	# Spawn ally units
	for spawn_data in current_map.ally_spawns:
		spawn_unit(spawn_data, Unit.Faction.ALLY)

# Spawn a single unit
func spawn_unit(spawn_data: Dictionary, faction: int) -> Unit:
	# Get unit class
	var unit_class: int = spawn_data.get("unit_class", Unit.UnitClass.WARRIOR)
	
	# Check if we have a scene for this unit class
	if not unit_scenes.has(unit_class):
		return null
	
	# Create unit instance
	var unit_scene = unit_scenes[unit_class]
	var unit_instance = unit_scene.instantiate()
	
	# Set unit properties
	unit_instance.unit_name = spawn_data.get("name", "Unit")
	unit_instance.unit_class = unit_class
	unit_instance.faction = faction
	unit_instance.level = spawn_data.get("level", 1)
	
	# Set position
	var pos_data = spawn_data.get("position", {"x": 0, "y": 0})
	var grid_pos = Vector2i(pos_data.x, pos_data.y)
	unit_instance.grid_position = grid_pos
	unit_instance.position = grid_system.grid_to_world(grid_pos)
	
	# Add to scene
	units_node.add_child(unit_instance)
	
	# Register with unit manager
	unit_manager.add_unit(unit_instance)
	
	return unit_instance

# Get map victory condition
func get_victory_condition() -> String:
	if current_map:
		return current_map.map_objective
	return "Defeat all enemies"

# Check if victory condition is met
func check_victory_condition() -> bool:
	if not current_map:
		return false
	
	match current_map.victory_condition:
		MapData.VictoryCondition.DEFEAT_ALL:
			return unit_manager.is_faction_defeated(Unit.Faction.ENEMY)
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
