class_name MovementManager
extends Node

var grid_size: Vector2i
var characters: Array[Character] = []

func _init(map_size: Vector2i, map_characters: Array[Character]):
	grid_size = map_size
	characters = map_characters

func spawn_character(character: Character, possiblePositions: Array[Vector2i]):
	# What do we do if none of the possible positions work? For now, just don't spawn.
	for position in possiblePositions:
		if is_valid_position(position, character):
			character.move_to(position, false)
			break

func is_valid_move(charMoves: Array[Vector2i], pos: Vector2i) -> bool:
	if !is_valid_position(pos):
		return false
	if not charMoves.has(pos):
		return false
	return true
	
func is_valid_position(pos: Vector2i, ignore_character: Character = null) -> bool:
	# Check if position is within map (rectangle)
	if pos.x < 0 or pos.y < 0 or pos.x >= grid_size.x or pos.y >= grid_size.y:
		return false
	# Check if position is occupied by another character
	var character_at_pos = get_character_at(pos)
	if character_at_pos != null and character_at_pos != ignore_character:
		return false
	return true

func get_character_at(grid_pos: Vector2i) -> Character:
	for character in characters:
		if GameBoard.world_to_grid(character.global_position) == grid_pos:
			return character
	return null

func get_valid_moves(character: Character) -> Array[Vector2i]:
	var moves = character.get_valid_move_positions()
	return moves.filter(func(pos): return is_valid_move(moves, pos))
	
