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
	ATTACK_DOWN,
	DEATH,
	TURN_COMPLETE
}

enum AttackType {
	PHYSICAL,
	MAGICAL,
	TRUE
}

var _color_highlight: Color = Color(1.4, 1.4, 1.4)

var unit_name: String = "Unit"
var unit_class: UnitClass = UnitClass.WARRIOR
var faction: int = Faction.PLAYER

var combat_stats: UnitCombatStats = UnitCombatStats.new()
var level: int = 1

# Calculated stats
var attack_type: AttackType= AttackType.PHYSICAL # This is calculated because some units may change attack type in battle
var health: int = combat_stats.max_health
var attacking_power: int:
	get:
		match attack_type:
			AttackType.PHYSICAL:
				return combat_stats.strength
			AttackType.MAGICAL:
				return combat_stats.magic
			AttackType.TRUE:
				return max(combat_stats.strength, combat_stats.magic, combat_stats.skill)
		return combat_stats.strength
var accuracy: int:
	get:
		return 75 + roundi(combat_stats.skill * 2.0)
var evasion: int:
	get:
		return floori((combat_stats.speed * 2 + combat_stats.skill) / 4.0)
var critical: int:
	get:
		return 5 + floori(combat_stats.skill / 2.0)

var can_counter_attack: bool = true
var can_act: bool = true
var can_move: bool = true

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

# Animation / graphics
var sprite_frames_res: SpriteFrames
var ui_icon_image = CompressedTexture2D

# Signals
signal defeated()
signal leveled_up(old_level: int, new_level: int)

@onready var sprite = $AnimatedSprite2D
@onready var hp_bar = $UnitHPBar

func _ready():
	# Set default unit name based on class if not specified
	if unit_name == "":
		unit_name = UnitClass.keys()[unit_class]
	set_state(UnitState.IDLE)
	
	if sprite_frames_res:
		sprite.sprite_frames = sprite_frames_res
	
	if hp_bar:
		hp_bar.update_health(health, combat_stats.max_health, faction)

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

		UnitState.TURN_COMPLETE:
			sprite.play("idle")
			modulate = Color(0.5, 0.5, 0.5)
			sprite.stop()
		
		UnitState.INACTIVE:
			sprite.play("idle")
			modulate = Color(1, 1, 1)
			sprite.stop()
			
		UnitState.DEATH:
			modulate = Color(1, 1, 1)
			sprite.play("death")

#endregion animation

#region combat/movement
func take_damage(amount: int) -> void:
	health -= amount
	health = max(0, health)
	
	if hp_bar:
		hp_bar.update_health(health, combat_stats.max_health, faction)
	
	if health <= 0:
		await _on_defeated()

func receive_healing(amount: int) -> void:
	health += amount
	health = min(health, combat_stats.max_health)
	
	if hp_bar:
		hp_bar.update_health(health, combat_stats.max_health, faction)

func _on_defeated() -> void:
	set_state(UnitState.DEATH)
	defeated.emit(self)
	
	await sprite.animation_finished
	queue_free()

func gain_experience(amount: int) -> void:
	combat_stats.experience += amount
	
	while combat_stats.experience >= combat_stats.exp_to_level:
		combat_stats.experience -= combat_stats.exp_to_level
		level_up()

func apply_levels() -> void:
	for lvl in range(level - 1):
		level_up(false)

func level_up(inc_lvl: bool = true) -> void:
	for stat_name in combat_stats.growth_rates:
		var growth_rate = combat_stats.growth_rates[stat_name]
		var roll = randi() % 100
		
		if roll < int(growth_rate):
			match stat_name:
				"hp":
					combat_stats.max_health += 2
					health += 2
				"strength":
					combat_stats.strength += 1
				"skill":
					combat_stats.skill += 1
				"magic":
					combat_stats.magic += 1
				"defense":
					combat_stats.defense += 1
				"resistance":
					combat_stats.resistance += 1
				"speed":
					combat_stats.speed += 1
	if inc_lvl:
		var old_level = level
		level += 1
		leveled_up.emit(old_level, level)

#endregion combat

func select() -> void:
	is_selected = true
	set_state(UnitState.SELECTED)

func deselect() -> void:
	is_selected = false
	if can_act or can_move:
		set_state(UnitState.IDLE)
	else:
		set_state(UnitState.TURN_COMPLETE)

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
