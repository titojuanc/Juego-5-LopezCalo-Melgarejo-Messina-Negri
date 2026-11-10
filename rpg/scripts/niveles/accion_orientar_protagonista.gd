extends "res://scripts/niveles/accion_evento.gd"
class_name AccionOrientarProtagonista

@export var mirar_a_la_izquierda: bool = false


func ejecutar(_disparador: Node2D) -> void:
	var jugador: Node = get_tree().get_first_node_in_group("Jugador")
	if jugador == null:
		push_warning("No se encontro al protagonista para cambiar su orientacion")
		return
	var sprite: AnimatedSprite2D = jugador.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null:
		push_warning("El protagonista no tiene un AnimatedSprite2D")
		return
	sprite.flip_h = mirar_a_la_izquierda
