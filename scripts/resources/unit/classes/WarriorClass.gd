extends GameUnit

@onready var audio_manager = $"/root/Main/GameManager/AudioManager"

func _init():
	combat_stats = UnitCombatStats.create({
		"max_health": 7,
		"strength": 5,
		"magic": 1,
		"skill": 3,
		"defense": 2,
		"resistance": 1,
		"speed": 5,
		"movement": 5,
		"attack_range": 1,
		"min_attack_range": 1,
		"growth_rates": {
			"hp": 75,
			"strength": 60,
			"magic": 10,
			"skill": 10,
			"defense": 45,
			"resistance": 25,
			"speed": 40
		}
	})

	unit_class = UnitClass.WARRIOR
	attack_type = GameUnit.AttackType.PHYSICAL
	health = combat_stats.max_health  # Initialize health to max health
	
	available_actions = [
		{"name": "Attack", "id": "attack"},
		{"name": "Wait", "id": "wait"}
	]

func _ready():
	super._ready()
	if sprite:
		sprite.frame_changed.connect(_on_animation_frame_changed)

func play_miss_audio():
	audio_manager.play_combat_sound("miss")

func play_flesh_dmg_audio():
	audio_manager.play_combat_sound("impact_flesh")

func play_blocked_audio():
	audio_manager.play_combat_sound("impact_blocked")

func play_critical_audio():
	audio_manager.play_combat_sound("critical")

func _on_animation_frame_changed():
	var current_anim = sprite.animation
	var current_frame = sprite.frame
	
	match current_anim:
		"attack_right", "attack_left", "attack_up", "attack_down":
			if current_frame == 2:
				audio_manager.play_combat_sound("blade_swing")
		"death":
			if current_frame == 1:
				audio_manager.play_combat_sound("death")
