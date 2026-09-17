extends Node2D
class_name PersonajeExplorador

@export var datos: RecursoPersonajeCombate

@onready var visual: Sprite2D = $CharacterBody2D/Visual

func _ready() -> void:
	if datos and datos.textura:
		visual.texture = datos.textura
