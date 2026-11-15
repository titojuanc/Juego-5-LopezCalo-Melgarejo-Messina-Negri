extends "res://scripts/niveles/accion_evento.gd"
class_name AccionMoralEvento

@export var accion: RecursoAccionMoral


func ejecutar(_disparador: Node2D) -> void:
	if accion ==null:
		push_warning("La accion moral del evento no tiene recurso asignado")
		return
	Alineamiento.aplicar_accion(accion)
