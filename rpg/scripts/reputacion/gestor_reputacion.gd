extends Node
class_name GestorReputacion

signal reputacion_cambiada(zona: String, valor: float)

const MINIMO := -100.0
const MAXIMO := 100.0

@export var zonas: Array[RecursoZona] = []

@export var puntos_por_notoriedad: float = 20.0

var _valores: Dictionary = {}

func _ready() -> void:
	Alineamiento.accion_aplicada.connect(_on_accion_aplicada)

func _on_accion_aplicada(accion: RecursoAccionMoral) -> void:
	var direccion = signf(accion.desplazamiento_bien)
	if direccion == 0.0:
		direccion = signf(accion.desplazamiento_ley)
	modificar(zona_actual(), accion.notoriedad * puntos_por_notoriedad * direccion)

func zona_actual() -> String:
	var escena = get_tree().current_scene
	if escena == null:
		return ""
	return escena.scene_file_path.get_base_dir()

func reputacion_de(zona: String) -> float:
	return _valores.get(zona, _inicial_de(zona))

func reputacion_actual() -> float:
	return reputacion_de(zona_actual())

func reputacion_global() -> float:
	var conocidas = _valores.keys()
	for zona in zonas:
		if not conocidas.has(zona.carpeta):
			conocidas.append(zona.carpeta)
	var total := 0.0
	for zona in conocidas:
		total += reputacion_de(zona)
	return total

func modificar(zona: String, cantidad: float) -> void:
	if zona.is_empty() or cantidad == 0.0:
		return
	_valores[zona] = clampf(reputacion_de(zona) + cantidad, MINIMO, MAXIMO)
	reputacion_cambiada.emit(zona, _valores[zona])

func nombre_de(zona: String) -> String:
	for datos in zonas:
		if datos.carpeta == zona:
			return datos.nombre
	return zona.get_file()

func _inicial_de(zona: String) -> float:
	for datos in zonas:
		if datos.carpeta == zona:
			return datos.reputacion_inicial
	return 0.0

func reiniciar() -> void:
	_valores.clear()
	reputacion_cambiada.emit(zona_actual(), reputacion_actual())

func a_diccionario() -> Dictionary:
	return {"valores": _valores.duplicate()}

func desde_diccionario(datos: Dictionary) -> void:
	_valores = datos.get("valores", {}).duplicate()
	reputacion_cambiada.emit(zona_actual(), reputacion_actual())
