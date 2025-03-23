extends Node2D

@onready var sprite: AnimatedSprite2D = $EffectSprite

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("default")

func _on_animation_finished():
	queue_free()
