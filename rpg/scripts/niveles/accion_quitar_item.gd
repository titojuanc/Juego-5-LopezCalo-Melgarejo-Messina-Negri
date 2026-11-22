extends "res://scripts/niveles/accion_evento.gd"
class_name AccionQuitarItem

# Saca items y/o oro del inventario compartido. Con quitar_por_tipo saca el primer item de ese tipo,
# sin importar cual sea (por ejemplo, cualquier item de vida).

@export var items: Array[RecursoItem] = []
@export var quitar_por_tipo: bool = false
@export var tipo: RecursoItem.TipoItem = RecursoItem.TipoItem.HP
@export var oro: int = 0
@export var mostrar_aviso: bool = true


func ejecutar(_disparador: Node2D) -> void:
	var quitados: Array[RecursoItem] = []
	for item in items:
		if(item != null and Equipo.inventario.has(item)):
			Equipo.inventario.erase(item)
			quitados.append(item)
	if quitar_por_tipo:
		for item in Equipo.inventario:
			if item != null and item.tipo ==tipo:
				Equipo.inventario.erase(item)
				quitados.append(item)
				break
	var pagado: int = mini(oro, Equipo.oro)
	Equipo.oro -= pagado
	if not quitados.is_empty():
		Equipo.equipo_cambiado.emit()
	if not mostrar_aviso:
		return
	var lineas: Array[String] = []
	for item in quitados:
		lineas.append("* Entregaste %s." % item.nombre)
	if pagado > 0:
		lineas.append("* Pagaste %d de oro." % pagado)
	if lineas.is_empty():
		return
	MotorDialogo.iniciar("", lineas)
	if MotorDialogo.activo:
		await MotorDialogo.dialogo_finalizado
