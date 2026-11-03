extends Node

signal flag_cambiado(nombre: StringName, valor: bool)

var en_curso: bool = false
var _flags: Dictionary = {}
var _eventos_completados: Dictionary = {}


func reiniciar_estado_partida() -> void:
	if en_curso:
		push_warning("No se puede reiniciar el estado mientras se ejecuta un evento")
		return
	_flags.clear()
	_eventos_completados.clear()


func obtener_flag(nombre: StringName, valor_por_defecto: bool = false) -> bool:
	if nombre.is_empty():
		return valor_por_defecto
	return bool(_flags.get(nombre, valor_por_defecto))


func cambiar_flag(nombre: StringName, valor: bool) -> void:
	if nombre.is_empty():
		push_warning("No se puede cambiar un flag con identificador vacio")
		return
	if obtener_flag(nombre) == valor and _flags.has(nombre):
		return
	_flags[nombre] = valor
	flag_cambiado.emit(nombre, valor)


func evento_completado(identificador: StringName) -> bool:
	return _eventos_completados.has(identificador)


func ejecutar_evento(disparador: Node2D) -> void:
	if en_curso or not is_instance_valid(disparador) or not disparador.puede_activarse():
		return
	var identificador: StringName = disparador.clave_evento()
	var solo_una_vez: bool = disparador.solo_una_vez
	if solo_una_vez and evento_completado(identificador):
		return
	en_curso = true
	disparador.establecer_en_curso(true)
	for accion in disparador.get_node("Acciones").get_children():
		if accion.has_method("ejecutar"):
			await accion.ejecutar(disparador)
	if solo_una_vez:
		_eventos_completados[identificador] = true
	if is_instance_valid(disparador):
		disparador.establecer_en_curso(false)
	en_curso = false
