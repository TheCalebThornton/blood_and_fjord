extends Node2D
class_name GameManager

enum GameState {
	MAIN_MENU,
	BATTLE_PREPARATION,
	PLAYER_TURN,
	ENEMY_TURN,
	ALLY_TURN,
	CUTSCENE,
	GAME_OVER,
	VICTORY
}

var current_state: int = GameState.MAIN_MENU

@onready var battle_manager: BattleManager = $BattleManager
@onready var unit_manager: UnitManager = $UnitManager
@onready var grid_system: GridSystem = $GridSystem
@onready var map_loader: MapLoader = $MapLoader
@onready var input_manager: InputManager = $InputManager
@onready var ui_manager: UIManager = $UIManager

var current_map: String = ""
var current_level: int = 0

signal state_changed(new_state: int)

func _ready():
	unit_manager.unit_turn_completed.connect(_check_faction_turn_ended)
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame
	load_level(0)

func change_state(new_state: int) -> void:
	current_state = new_state
	
	match new_state:
		GameState.PLAYER_TURN:
			start_faction_turn(GameUnit.Faction.PLAYER)
		GameState.ALLY_TURN:
			start_faction_turn(GameUnit.Faction.ALLY)
		GameState.ENEMY_TURN:
			start_faction_turn(GameUnit.Faction.ENEMY)
		GameState.VICTORY:
			handle_victory()
		GameState.GAME_OVER:
			handle_game_over()
	
	# Emit signal for UI and other systems
	state_changed.emit(new_state)

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
			change_state(GameState.ALLY_TURN)
		else:
			change_state(GameState.ENEMY_TURN)
	elif faction == GameUnit.Faction.ALLY:
		change_state(GameState.ENEMY_TURN)
	elif faction == GameUnit.Faction.ENEMY:
		change_state(GameState.PLAYER_TURN)

func handle_victory() -> void:
	# TODO Save progress, show victory screen, etc.
	print("Victory!")
	ui_manager.announce_level_end(true)
	
	# In a real game, you'd show a victory screen
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
	
	if map_loader.load_map(map_path):
		change_state(GameState.PLAYER_TURN)
	else:
		print("Failed to load level ", level_number)

func restart_level() -> void:
	load_level(current_level)

func _check_faction_turn_ended(unit: GameUnit):
	if unit_manager.are_all_faction_units_done(unit.faction):
		end_faction_turn(unit.faction)
	
