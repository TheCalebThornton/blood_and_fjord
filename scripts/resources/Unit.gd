extends Node2D
class_name Unit

# Faction enum
enum Faction {
	PLAYER,
	ENEMY,
	ALLY
}

# Unit type/class
enum UnitClass {
	WARRIOR,
	ARCHER,
	MAGE,
	HEALER,
	CAVALRY,
	FLIER,
	KNIGHT
}

# Basic unit properties
var unit_name: String = "Unit"
var unit_class: UnitClass = UnitClass.WARRIOR
var faction: int = Faction.PLAYER
var level: int = 1
var health: int = 10
var max_health: int = 10
var movement: int = 4
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

# Unit state
var has_moved: bool = false
var has_acted: bool = false
var is_selected: bool = false
var team: int = 0  # 0 = player, 1 = enemy

var grid_position: Vector2i = Vector2i(0, 0)

# References
var battle_manager = null

# Signals
signal moved(from_pos: Vector2i, to_pos: Vector2i)
# signal attacked(target: Unit)
signal damaged(amount: int)
# signal healed(amount: int)
signal defeated()
signal leveled_up(old_level: int, new_level: int)

# Sprite and animation references
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
	health = max_health
	
	# Set default unit name based on class if not specified
	if unit_name == "":
		unit_name = UnitClass.keys()[unit_class]

#region animation
func play_move_animation(path: Array) -> void:
	# This would be implemented with a tween or animation
	# For now, just teleport
	position = get_parent().grid_system.grid_to_world(grid_position)

func play_attack_animation() -> void:
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")

func play_damage_animation() -> void:
	if animation_player and animation_player.has_animation("damage"):
		animation_player.play("damage")

func play_defeat_animation() -> void:
	if animation_player and animation_player.has_animation("defeat"):
		animation_player.play("defeat")
#endregion animation

# region combat/movement
func reset_turn() -> void:
	has_moved = false
	has_acted = false

func move_to(new_position: Vector2i) -> void:
	grid_position = new_position
	position = Vector2(new_position.x * 64, new_position.y * 64)
	has_moved = true

func set_grid_position(pos: Vector2i) -> void:
	var old_pos = grid_position
	grid_position = pos
	
	# Update visual position
	position = get_parent().grid_system.grid_to_world(pos)
	
	# Emit signal
	moved.emit(old_pos, pos)

func perform_attack(target) -> Dictionary:
	has_acted = true
	
	# Calculate damage based on attack type
	var damage = 0
	var is_magical = unit_class == UnitClass.MAGE || unit_class == UnitClass.HEALER
	
	if is_magical:
		damage = magic - target.resistance
	else:
		damage = attack - target.defense
	
	# Ensure minimum damage of 1
	damage = max(1, damage)
	
	# Apply damage
	target.take_damage(damage)
	
	return {
		"attacker": self,
		"target": target,
		"damage": damage,
		"is_magical": is_magical
	}

func take_damage(amount: int) -> void:
	health -= amount
	health = max(0, health)
	
	# Emit signal
	damaged.emit(amount)
	
	# Check if defeated
	if health <= 0:
		_on_defeated()

func heal_target(target) -> Dictionary:
	has_acted = true
	
	# Calculate healing amount (based on magic stat)
	var heal_amount = magic / 2
	heal_amount = max(1, heal_amount)
	
	# Apply healing
	target.receive_healing(heal_amount)
	
	return {
		"healer": self,
		"target": target,
		"amount": heal_amount
	}

func receive_healing(amount: int) -> void:
	health += amount
	health = min(health, max_health)

# TODO Handle death
func _on_defeated() -> void:
	# Emit signal
	defeated.emit()
	
	# Visual feedback
	modulate = Color(0.5, 0.5, 0.5, 0.5)
	
	# Unit will be removed by UnitManager

func gain_experience(amount: int) -> void:
	experience += amount
	
	# Check for level up
	while experience >= exp_to_level:
		experience -= exp_to_level
		level_up()

func level_up() -> void:
	var old_level = level
	level += 1
	
	# Increase stats based on growth rates
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
	
	# Emit signal
	leveled_up.emit(old_level, level)
# endregion combat

# UI and visual methods
func select() -> void:
	is_selected = true
	# TODO Visual indication of selection will be added later

func deselect() -> void:
	is_selected = false
	# TODO Remove visual indication

func get_attack_targets() -> Array:
	# This will be implemented to return valid attack targets
	# For now, return an empty array
	return []

func get_movement_range() -> Array:
	# This will be implemented to return valid movement tiles
	# For now, return an empty array
	return []

func get_class_name() -> String:
	return UnitClass.keys()[unit_class] 

func get_description() -> String:
	return "%s (Lv. %d %s)" % [unit_name, level, UnitClass.keys()[unit_class]]
