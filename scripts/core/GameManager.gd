extends Node2D
class_name GameManager

enum GameState {
	MAIN_MENU,
	BATTLE_PREPARATION,
	BATTLE
}

enum BattleState {
	PLAYER_TURN,
	ENEMY_TURN,
	ALLY_TURN,
	GAME_OVER,
	VICTORY
}

var current_game_state: GameState
var current_battle_state: BattleState

@onready var battle_manager: BattleManager = $BattleManager
@onready var unit_manager: UnitManager = $UnitManager
@onready var grid_system: GridSystem = $GridSystem
@onready var map_loader: MapLoader = $MapLoader
@onready var input_manager: InputManager = $InputManager
@onready var ui_manager: UIManager = $UIManager
@onready var game_menu: GameMenu = $UIManager/GameMenu
@onready var units_node: Node2D = $"../Units"
@onready var terrain_node: Node2D = $"../Terrain"
@onready var battle_menu: BattleMenu = $UIManager/BattleUIContainer/Panel/MarginContainer/BattleMenu

var current_map: String = ""
var current_level: int = 0
var player_unit_data: Array[UnitData] = []

signal game_state_changed(new_state: GameState)
signal battle_state_changed(new_state: BattleState)

func _ready():
	unit_manager.unit_turn_completed.connect(_check_faction_turn_ended)
	battle_menu.battle_menu_action.connect(_on_battle_menu_action)
	game_menu.start_new_battle.connect(_on_start_new_battle)
	game_menu.resume_saved_battle.connect(_on_resume_battle)
	
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame
	change_game_state(GameState.MAIN_MENU)

func change_game_state(new_state: GameState) -> void:
	current_game_state = new_state
	
	match new_state:
		GameState.MAIN_MENU:
			units_node.hide()
			terrain_node.hide()
			
			game_menu.show_game_menu()
		GameState.BATTLE_PREPARATION:
			pass
		GameState.BATTLE:
			units_node.show()
			terrain_node.show()
			game_menu.hide()
			load_level(current_level)
			
	game_state_changed.emit(new_state)

func change_battle_state(new_state: BattleState) -> void:
	current_battle_state = new_state
	
	match new_state:
		BattleState.PLAYER_TURN:
			start_faction_turn(GameUnit.Faction.PLAYER)
		BattleState.ALLY_TURN:
			start_faction_turn(GameUnit.Faction.ALLY)
		BattleState.ENEMY_TURN:
			start_faction_turn(GameUnit.Faction.ENEMY)
		BattleState.VICTORY:
			handle_victory()
		BattleState.GAME_OVER:
			handle_game_over()
	
	battle_state_changed.emit(new_state)

func start_faction_turn(faction: GameUnit.Faction) -> void:
	unit_manager.prepare_faction_units_for_turn(faction)
	ui_manager.announce_faction_turn(faction)
	
	if faction == GameUnit.Faction.PLAYER:
		input_manager.change_state(input_manager.InputState.GRID_SELECTION)
	elif faction == GameUnit.Faction.ALLY:
		input_manager.change_state(input_manager.InputState.LOCKED)
		# TODO implement Ally AI
		await get_tree().create_timer(1.0).timeout
		end_faction_turn(faction)
	elif faction == GameUnit.Faction.ENEMY:
		input_manager.change_state(input_manager.InputState.LOCKED)
		# TODO implement Enemy AI
		await get_tree().create_timer(1.0).timeout
		end_faction_turn(faction)

func end_faction_turn(faction: GameUnit.Faction) -> void:
	unit_manager.force_faction_end(faction)
	if faction == GameUnit.Faction.PLAYER:
		if unit_manager.ally_units.size() > 0:
			change_battle_state(BattleState.ALLY_TURN)
		else:
			change_battle_state(BattleState.ENEMY_TURN)
	elif faction == GameUnit.Faction.ALLY:
		change_battle_state(BattleState.ENEMY_TURN)
	elif faction == GameUnit.Faction.ENEMY:
		change_battle_state(BattleState.PLAYER_TURN)

func handle_victory() -> void:
	# TODO Save progress, show victory screen, etc.
	print("Victory!")
	ui_manager.announce_level_end(true)
	
	# For now, just restart the level after a delay
	await get_tree().create_timer(3.0).timeout
	restart_level()

func handle_game_over() -> void:
	# TODO Show game over screen, offer restart, etc.
	print("Game Over!")
	ui_manager.announce_level_end(false)
	
	# In a real game, you'd show a game over screen
	# For now, just restart the level after a delay
	await get_tree().create_timer(3.0).timeout
	restart_level()

func load_level(level_number: int) -> void:
	current_level = level_number
	
	# Load specific map based on level number
	var map_str = "res://maps/level_{level}.json"
	var map_path = map_str.format({"level": level_number})
	
	if map_loader.load_map(map_path, player_unit_data):
		change_battle_state(BattleState.PLAYER_TURN)
	else:
		print("Failed to load level ", level_number)

func restart_level() -> void:
	load_level(current_level)

func _check_faction_turn_ended(unit: GameUnit) -> void:
	if unit_manager.are_all_faction_units_done(unit.faction):
		end_faction_turn(unit.faction)

func _on_battle_menu_action(action: BattleMenu.MenuActions) -> void:

	match action:
		BattleMenu.MenuActions.QuitToMenu:
			change_game_state(GameState.MAIN_MENU)
		BattleMenu.MenuActions.Surrender:
			handle_game_over()
		BattleMenu.MenuActions.EndTurn:
			var faction = null
			match current_battle_state:
				BattleState.PLAYER_TURN:
					faction = GameUnit.Faction.PLAYER
				BattleState.ENEMY_TURN:
					faction = GameUnit.Faction.ENEMY
				BattleState.ALLY_TURN:
					faction = GameUnit.Faction.ALLY
			if not faction == null:
				end_faction_turn(faction)

func _on_start_new_battle(units: Array[UnitData]) -> void:
	player_unit_data = units
	change_game_state(GameState.BATTLE)

func _on_resume_battle() -> void:
	player_unit_data = load_player_units()
	change_game_state(GameState.BATTLE)

func load_player_units() -> Array[UnitData]:
	var units: Array[UnitData] = []
	var file = FileAccess.open("res://saveData/player.json", FileAccess.READ)
	
	if file == null:
		print("Error loading player data: ", FileAccess.get_open_error())
		return units
	
	var json_text = file.get_as_text()
	var json = JSON.parse_string(json_text)
	
	if json == null:
		print("Error parsing player data JSON")
		return units
	
	if not json.has("units"):
		print("Player data missing units array")
		return units
	
	for unit_data in json["units"]:
		var unit = UnitData.new()
		unit.unit_name = unit_data["name"]
		unit.unit_class = unit_data["unit_class"]
		unit.sprite_color = unit_data["sprite_color"]
		unit.level = unit_data["level"]
		units.append(unit)
	
	return units

	
