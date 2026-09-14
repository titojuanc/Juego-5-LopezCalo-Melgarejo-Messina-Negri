extends Node2D
class_name PersonajeExplorador

@export var datos: RecursoPersonajeCombate

@onready var visual: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D

func _ready() -> void:
	if datos and datos.sprite_frames:
		visual.sprite_frames = datos.sprite_frames
		visual.play("default")
