extends Node2D
class_name PlayerSaveData

# Units data
var units: Array[Dictionary] = []

# Unlock progress
var unlocked_armies: Array = []
var unlocked_auras: Array = []
var current_level: int = 0

# Battle statistics for unlock conditions
var rounds_survived: int = 0
var damage_taken: int = 0
var allies_defeated: int = 0
var enemies_defeated: int = 0

const SAVE_PATH = "res://saveData/player.json"

func load_from_json() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file at path: " + SAVE_PATH)
		return
		
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		push_error("Failed to parse JSON: " + json.get_error_message())
		return
		
	var json_data = json.get_data()
	
	# Load units with their full data structure
	var loaded_units = json_data.get("units", [])
	units.clear()
	for unit_data in loaded_units:
		units.append({
			"name": unit_data.get("name", ""),
			"unit_class": unit_data.get("unit_class", ""),
			"sprite_color": unit_data.get("sprite_color", ""),
			"level": unit_data.get("level", 1)
		})
	
	unlocked_armies = json_data.get("unlocked_armies", [])
	unlocked_auras = json_data.get("unlocked_auras", [])
	current_level = json_data.get("current_level", 0)
	rounds_survived = json_data.get("rounds_survived", 0)
	damage_taken = json_data.get("damage_taken", 0)
	allies_defeated = json_data.get("allies_defeated", 0)
	enemies_defeated = json_data.get("enemies_defeated", 0)

func save_to_json() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing at path: " + SAVE_PATH)
		return
		
	var json_data = to_json()
	var json_text = JSON.stringify(json_data, "\t")
	file.store_string(json_text)
	file.close()

func to_json() -> Dictionary:
	return {
		"units": units,
		"unlocked_armies": unlocked_armies,
		"unlocked_auras": unlocked_auras,
		"current_level": current_level,
		"rounds_survived": rounds_survived,
		"damage_taken": damage_taken,
		"allies_defeated": allies_defeated,
		"enemies_defeated": enemies_defeated
	}
