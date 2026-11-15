extends "res://scripts/niveles/accion_evento.gd"
class_name AccionCondicion

# Ejecuta sus acciones hijas en orden solo si se cumplen todas las condiciones configuradas.

@export_group("Flag")
@export var flag_requerido: StringName = &""
@export var valor_flag_requerido: bool = true

@export_group("Party")
@export var miembros_presentes: Array[RecursoPersonajeCombate] = []
@export var miembros_ausentes: Array[RecursoPersonajeCombate] = []
@export var reclutado_primero: RecursoPersonajeCombate
@export var reclutado_despues: RecursoPersonajeCombate

@export_group("Alineamiento del protagonista")
@export_range(-1.0, 1.0, 0.01) var ley_minima: float = -1.0
@export_range(-1.0, 1.0, 0.01) var ley_maxima: float = 1.0
@export_range(-1.0, 1.0, 0.01) var bien_minimo: float = -1.0
@export_range(-1.0, 1.0, 0.01) var bien_maximo: float = 1.0

@export_group("Opinion de un sidekick")
@export var miembro_opinion: RecursoPersonajeCombate
@export var estado_opinion: CalculoAlineamiento.Estado = CalculoAlineamiento.Estado.AMISTOSO


func ejecutar(disparador: Node2D) -> void:
	if not se_cumple():
		return
	for accion in get_children():
		if accion.has_method("ejecutar"):
			await accion.ejecutar(disparador)


func se_cumple() -> bool:
	if not flag_requerido.is_empty() and GestorEventos.obtener_flag(flag_requerido) != valor_flag_requerido:
		return false
	for miembro in miembros_presentes:
		if miembro != null and not Equipo.miembros.has(miembro):
			return false
	for miembro in miembros_ausentes:
		if(miembro != null and Equipo.miembros.has(miembro)):
			return false
	if reclutado_primero != null and reclutado_despues != null:
		if not Equipo.reclutado_antes(reclutado_primero, reclutado_despues):
			return false
	if Alineamiento.ley < ley_minima or Alineamiento.ley > ley_maxima:
		return false
	if Alineamiento.bien < bien_minimo or Alineamiento.bien >bien_maximo:
		return false
	if miembro_opinion != null:
		if miembro_opinion.perfil ==null:
			push_warning("%s no tiene perfil de alineamiento" % miembro_opinion.nombre)
			return false
		if Alineamiento.calcular(miembro_opinion.perfil).estado != estado_opinion:
			return false
	return true
