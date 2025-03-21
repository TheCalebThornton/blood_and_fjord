extends Node2D
class_name GameUnit

enum Faction {
	PLAYER,
	ENEMY,
	ALLY
}

enum UnitClass {
	WARRIOR,
	ARCHER,
	MAGE,
	HEALER,
	CAVALRY,
	FLIER,
	KNIGHT
}

enum UnitState {
	IDLE,
	MOVING_RIGHT,
	MOVING_LEFT,
	SELECTED,
	INACTIVE,
	ATTACK_LEFT,
	ATTACK_RIGHT,
	ATTACK_UP,
	ATTACK_DOWN
}

var _color_highlight: Color = Color(1.4, 1.4, 1.4)

# Basic unit properties
var unit_name: String = "Unit"
var unit_class: UnitClass = UnitClass.WARRIOR
var faction: int = Faction.PLAYER
var level: int = 1
var health: int = 10
var max_health: int = 10
var movement: int = 8
var attack: int = 5
var defense: int = 5
var magic: int = 2
var resistance: int = 2
var speed: int = 5
var accuracy: int = 85
var evasion: int = 10
var critical: int = 5
var attack_range: int = 1
var min_attack_range: int = 1
var can_counter_attack: bool = true
var can_act: bool = true
var can_move: bool = true
var experience: int = 0
var exp_to_level: int = 100
var growth_rates: Dictionary = {
	"hp": 60,        # 60% chance to gain 1 HP on level up
	"attack": 40,    # 40% chance to gain 1 Attack on level up
	"defense": 30,   # etc.
	"magic": 20,
	"resistance": 25,
	"speed": 35
}
var inventory: Array = []
var equipped_weapon = null
var available_actions: Array[Dictionary] = [
	{"name": "Attack", "id": "attack"},
	{"name": "Wait", "id": "wait"}
]

# Unit state
var current_state: int
var has_moved: bool = false
var has_acted: bool = false
var is_selected: bool = false

var grid_position: Vector2i = Vector2i(0, 0)
var original_position: Vector2i

# References
var battle_manager = null

# Signals
signal damaged(amount: int)
signal defeated()
signal leveled_up(old_level: int, new_level: int)

@onready var sprite = $AnimatedSprite2D

func _ready():
	health = max_health
	
	# Set default unit name based on class if not specified
	if unit_name == "":
		unit_name = UnitClass.keys()[unit_class]
	set_state(UnitState.IDLE)

#region animation
func set_state(new_state: UnitState):
	current_state = new_state
	match current_state:
		UnitState.IDLE:
			modulate = Color(1, 1, 1)
			if sprite:
				sprite.play("idle")

		UnitState.MOVING_RIGHT:
			modulate = _color_highlight
			if sprite:
				sprite.flip_h = false
				sprite.play("move_right")

		UnitState.MOVING_LEFT:
			modulate = _color_highlight
			if sprite:
				sprite.flip_h = true
				# Moving right but flipped
				sprite.play("move_right")

		UnitState.ATTACK_RIGHT:
			modulate = _color_highlight
			if sprite:
				sprite.flip_h = false
				sprite.play("attack_right")

		UnitState.ATTACK_LEFT:
			modulate = _color_highlight
			if sprite:
				sprite.flip_h = true
				sprite.play("attack_right")

		UnitState.ATTACK_UP:
			modulate = _color_highlight
			if sprite:
				sprite.play("attack_up")

		UnitState.ATTACK_DOWN:
			modulate = _color_highlight
			if sprite:
				sprite.play("attack_down")

		UnitState.SELECTED:
			modulate = _color_highlight
			sprite.play("selected")

		UnitState.INACTIVE:
			modulate = Color(0.5, 0.5, 0.5)
			sprite.stop()

#endregion animation

#region combat/movement
func reset_turn() -> void:
	has_moved = false
	has_acted = false

func take_damage(amount: int) -> void:
	health -= amount
	health = max(0, health)
	
	damaged.emit(amount)
	
	if health <= 0:
		_on_defeated()

func receive_healing(amount: int) -> void:
	health += amount
	health = min(health, max_health)

# TODO Handle death
func _on_defeated() -> void:
	defeated.emit()
	
	modulate = Color(0.5, 0.5, 0.5, 0.5)
	

func gain_experience(amount: int) -> void:
	experience += amount
	
	while experience >= exp_to_level:
		experience -= exp_to_level
		level_up()

func level_up() -> void:
	var old_level = level
	level += 1
	
	for stat in growth_rates:
		var growth = growth_rates[stat]
		var roll = randi() % 100
		
		if roll < growth:
			match stat:
				"hp":
					max_health += 1
					health += 1
				"attack":
					attack += 1
				"defense":
					defense += 1
				"magic":
					magic += 1
				"resistance":
					resistance += 1
				"speed":
					speed += 1
	
	leveled_up.emit(old_level, level)
#endregion combat

func select() -> void:
	is_selected = true
	set_state(UnitState.SELECTED)

func deselect() -> void:
	is_selected = false
	set_state(UnitState.IDLE)

func get_class_name() -> String:
	return UnitClass.keys()[unit_class] 

func get_description() -> String:
	return "%s (Lv. %d %s)" % [unit_name, level, UnitClass.keys()[unit_class]]

func get_available_actions() -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	
	# Only add attack if unit can act
	if can_act:
		actions.append({"name": "Attack", "id": "attack"})
	
	# Wait is always available
	actions.append({"name": "Wait", "id": "wait"})
	
	return actions
