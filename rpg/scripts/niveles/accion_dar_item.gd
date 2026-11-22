extends "res://scripts/niveles/accion_evento.gd"
class_name AccionDarItem

# Agrega items (y opcionalmente oro) al inventario compartido de la party.
# Usarla dentro de las Acciones de un DisparadorEvento con solo_una_vez para
# que el objeto se entregue una sola vez.

@export var items: Array[RecursoItem] = []
@export var oro: int = 0
@export var mostrar_aviso: bool = true


func ejecutar(_disparador: Node2D) -> void:
	Equipo.agregar_items(items)
	if oro != 0:
		Equipo.oro += oro
	if not mostrar_aviso:
		return
	var lineas: Array[String] = []
	for item in items:
		if item != null:
			lineas.append("* Obtuviste %s." % item.nombre)
	if oro > 0:
		lineas.append("* Obtuviste %d de oro." % oro)
	if lineas.is_empty():
		return
	MotorDialogo.iniciar("", lineas)
	if MotorDialogo.activo:
		await MotorDialogo.dialogo_finalizado
