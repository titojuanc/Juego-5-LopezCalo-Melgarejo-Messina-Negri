extends "res://scripts/niveles/accion_evento.gd"
class_name AccionAnimacionEvento

@export_node_path("AnimationPlayer") var ruta_reproductor: NodePath
@export var animacion: StringName = &""
@export var esperar_finalizacion: bool = true


func ejecutar(_disparador: Node2D) -> void:
	var reproductor: AnimationPlayer = get_node_or_null(ruta_reproductor) as AnimationPlayer
	if reproductor == null or not reproductor.has_animation(animacion):
		push_warning("La accion de animacion no tiene un AnimationPlayer o animacion valida")
		return
	reproductor.play(animacion)
	if esperar_finalizacion:
		await reproductor.animation_finished
