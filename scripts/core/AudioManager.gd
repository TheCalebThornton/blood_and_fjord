extends Node
class_name AudioManager

# Audio buses for different types of sounds
const MASTER_BUS = "Master"
const SFX_BUS = "SFX"
const MUSIC_BUS = "Music"

# Volume ranges (in decibels)
const MIN_VOLUME_DB = -80.0  # Effectively silent
const MAX_VOLUME_DB = 0.0    # Full volume

# Current volume settings (0.0 to 1.0)
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

# Preloaded sound effects
var ui_sounds = {
	"button_focus": preload("res://assets/audio/ui/button_focus.wav"),
	"button_click": preload("res://assets/audio/ui/button_click.wav"),
	"menu_open": preload("res://assets/audio/ui/menu_open.wav"),
	"menu_close": preload("res://assets/audio/ui/menu_close.wav"),
	"error": preload("res://assets/audio/ui/error.wav"),
	"cursor_move": preload("res://assets/audio/ui/cursor_move.wav"),
}

var combat_sounds = {
	"character_select": preload("res://assets/audio/combat/character_select.wav"),
	"character_unselect": preload("res://assets/audio/combat/character_unselect.wav"),
	"blade_swing": preload("res://assets/audio/combat/blade_swing.wav"),
	"impact_flesh": preload("res://assets/audio/combat/impact_flesh.wav"),
	"impact_blocked": preload("res://assets/audio/combat/impact_blocked.wav"),
	"miss": preload("res://assets/audio/combat/miss.wav"),
	"death": preload("res://assets/audio/combat/death.wav"),
	"critical": preload("res://assets/audio/combat/critical.wav"),
}

var audio_players: Array[AudioStreamPlayer] = []
const PLAYERS_POOL_SIZE = 4

func _ready():
	for i in range(PLAYERS_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		audio_players.append(player)
	
	set_master_volume(master_volume)
	set_sfx_volume(sfx_volume)
	set_music_volume(music_volume)

func linear_to_db(linear: float) -> float:
	if linear <= 0:
		return MIN_VOLUME_DB
	return 20.0 * log(linear) / log(10.0)

func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(MASTER_BUS),
		linear_to_db(master_volume)
	)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	if AudioServer.get_bus_index(SFX_BUS) >= 0:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(SFX_BUS),
			linear_to_db(sfx_volume)
		)

func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	if AudioServer.get_bus_index(MUSIC_BUS) >= 0:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(MUSIC_BUS),
			linear_to_db(music_volume)
		)

func play_combat_sound(sound_name: String, volume_override: float = 1.0) -> void:
	if not combat_sounds.has(sound_name):
		push_warning("Sound not found: " + sound_name)
		return
	_play_sound(combat_sounds[sound_name], volume_override)

func play_ui_sound(sound_name: String, volume_override: float = 1.0) -> void:
	if not ui_sounds.has(sound_name):
		push_warning("Sound not found: " + sound_name)
		return
	_play_sound(ui_sounds[sound_name], volume_override)

func _play_sound(sound: AudioStream, volume_override: float = 1.0) -> void:
	var player = _get_available_player()
	if player:
		player.stream = sound
		player.volume_db = linear_to_db(volume_override)
		player.play()

func _get_available_player() -> AudioStreamPlayer:
	for player in audio_players:
		if not player.playing:
			return player
	
	return audio_players[0] 

# Save volume settings (you can call this when the game is closing or when settings change)
func save_volume_settings() -> void:
	var settings = {
		"master_volume": master_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume
	}
	# Save to a config file or your game's save system
	# This is just an example - implement according to your save system
	var config = ConfigFile.new()
	config.set_value("audio", "volumes", settings)
	config.save("user://audio_settings.cfg")

# Load volume settings
func load_volume_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://audio_settings.cfg") == OK:
		var settings = config.get_value("audio", "volumes", {
			"master_volume": 1.0,
			"sfx_volume": 1.0,
			"music_volume": 1.0
		})
		set_master_volume(settings.master_volume)
		set_sfx_volume(settings.sfx_volume)
		set_music_volume(settings.music_volume) 
