extends Node
class_name GestorEquipo

signal equipo_cambiado

var maximo: int = 3

var miembros: Array[RecursoPersonajeCombate] = []

func establecer(nuevos: Array[RecursoPersonajeCombate]) -> void:
	miembros = nuevos.slice(0, maximo)
	equipo_cambiado.emit()

func agregar(miembro: RecursoPersonajeCombate) -> void:
	if miembro == null or miembros.has(miembro) or miembros.size() >= maximo:
		return
	miembros.append(miembro)
	equipo_cambiado.emit()

func quitar(miembro: RecursoPersonajeCombate) -> void:
	if not miembros.has(miembro):
		return
	miembros.erase(miembro)
	equipo_cambiado.emit()

func lider() -> RecursoPersonajeCombate:
	if miembros.is_empty():
		return null
	return miembros[0]

func seguidores() -> Array:
	return miembros.slice(1)

func a_diccionario() -> Dictionary:
	return {"miembros": miembros.map(func(m): return m.resource_path)}

func desde_diccionario(datos: Dictionary) -> void:
	var nuevos: Array[RecursoPersonajeCombate] = []
	for ruta in datos.get("miembros", []):
		var miembro = load(ruta)
		if miembro is RecursoPersonajeCombate:
			nuevos.append(miembro)
	establecer(nuevos)
