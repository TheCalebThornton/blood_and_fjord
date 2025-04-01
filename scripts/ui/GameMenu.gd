extends PanelContainer
class_name GameMenu

enum MenuState {
	HOME,
	NEW_GAME,
	UNLOCKABLES,
	CLASS_INFO,
}

@onready var input_manager: InputManager = $"../../InputManager"
@onready var home_view: HomeView = $HomeView
@onready var new_game_view: PanelContainer = $NewGameView
@onready var unlockables_view: PanelContainer = $UnlockablesView
@onready var class_info_view: PanelContainer = $ClassInfoView

signal start_new_battle()
signal resume_saved_battle()

var current_state: MenuState

func _ready() -> void:
	home_view.home_menu_action.connect(_on_home_view_action_clicked)
	new_game_view.start_new_game.connect(_on_start_new_game_clicked)
	hide()
	
func set_menu_state(menu_state: MenuState) -> void:
	current_state = menu_state
	match menu_state:
		MenuState.HOME:
			_hide_all_views()
			home_view.show_menu()
			input_manager.change_state(InputManager.InputState.GAME_MENU_HOME)
		MenuState.NEW_GAME:
			_hide_all_views()
			new_game_view.show_menu()
			input_manager.change_state(InputManager.InputState.GAME_MENU_NEW_GAME)
		MenuState.UNLOCKABLES:
			_hide_all_views()
			unlockables_view.show_menu()
			input_manager.change_state(InputManager.InputState.GAME_MENU_UNLOCKABLES)
		MenuState.CLASS_INFO:
			_hide_all_views()
			class_info_view.show_menu()
			input_manager.change_state(InputManager.InputState.GAME_MENU_CLASS_INFO)

func show_game_menu() -> void:
	set_menu_state(MenuState.HOME)
	show()

func _hide_all_views() -> void:
	home_view.hide()
	new_game_view.hide()
	unlockables_view.hide()
	class_info_view.hide()

func _on_home_view_action_clicked(menu_action: HomeView.MenuActions) -> void:
	match menu_action:
		home_view.MenuActions.NEW_GAME:
			set_menu_state(MenuState.NEW_GAME)
		home_view.MenuActions.RESUME:
			# assume home_view checked for save state before firing
			resume_saved_battle.emit()
		home_view.MenuActions.UNLOCKABLES:
			pass
		home_view.MenuActions.CLASS_INFO:
			pass

func _on_start_new_game_clicked(units: Array[UnitData]) -> void:
	start_new_battle.emit(units)
