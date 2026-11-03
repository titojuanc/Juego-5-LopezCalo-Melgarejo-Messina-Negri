extends CharacterBody2D
class_name Seguidor

@export var datos: RecursoPersonajeCombate

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if datos:
		name = datos.nombre

func mover_a(destino: Vector2, delta: float) -> void:
	var anterior = global_position
	velocity = (destino - global_position) / delta
	move_and_slide()
	var movimiento = global_position - anterior
	if movimiento.length() < 0.5:
		quieto()
		return
	sprite.play("Walk")
	if movimiento.x < -0.1:
		sprite.flip_h = true
	elif movimiento.x > 0.1:
		sprite.flip_h = false

func quieto() -> void:
	velocity = Vector2.ZERO
	sprite.play("Idle")
