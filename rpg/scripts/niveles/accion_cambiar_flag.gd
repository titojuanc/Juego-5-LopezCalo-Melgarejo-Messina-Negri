extends "res://scripts/niveles/accion_evento.gd"
class_name AccionCambiarFlag

@export var nombre_flag: StringName = &""
@export var valor: bool = true


func ejecutar(_disparador: Node2D) -> void:
	GestorEventos.cambiar_flag(nombre_flag, valor)
