extends Resource
class_name CharacterStats

@export var name: String
@export var max_hp: int
@export var strength: int
@export var defense: int
@export var speed: int
@export var movement: int

var current_hp: int

func _init():
	current_hp = max_hp 
